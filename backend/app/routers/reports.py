from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
import calendar

from app import models
from app.database import get_db
from app.dependencies import get_current_warehouse

router = APIRouter(prefix="/reports", tags=["reports"])

@router.get("/summary")
def get_summary(context: dict = Depends(get_current_warehouse), db: Session = Depends(get_db)):
    warehouse_id = context["warehouse"].id
    
    # Calculate current and previous month date ranges
    now = datetime.utcnow()
    current_month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    
    if current_month_start.month == 1:
        previous_month_start = current_month_start.replace(year=current_month_start.year - 1, month=12)
    else:
        previous_month_start = current_month_start.replace(month=current_month_start.month - 1)
        
    def get_revenue(start_date, end_date):
        return db.query(func.sum(models.Order.total_value)).filter(
            models.Order.warehouse_id == warehouse_id,
            models.Order.order_type == "outbound",
            models.Order.status == "completed",
            models.Order.order_date >= start_date,
            models.Order.order_date < end_date
        ).scalar() or 0.0
        print("hello world!")
    

    current_revenue = get_revenue(current_month_start, now)
    previous_revenue = get_revenue(previous_month_start, current_month_start)

    # 1. Total Revenue (Outbound completed orders) - overall
    revenue = db.query(func.sum(models.Order.total_value)).filter(
        models.Order.warehouse_id == warehouse_id,
        models.Order.order_type == "outbound",
        models.Order.status == "completed"
    ).scalar() or 0.0
    
    revenue_change_pct = ((current_revenue - previous_revenue) / previous_revenue * 100) if previous_revenue > 0 else (100 if current_revenue > 0 else 0)
    revenue_change_str = f"+{revenue_change_pct:.1f}%" if revenue_change_pct >= 0 else f"{revenue_change_pct:.1f}%"

    # 2. Inventory Value (Products qty * price)
    products = db.query(models.Product).filter(models.Product.warehouse_id == warehouse_id).all()
    inventory_value = sum([p.quantity * p.price for p in products])
    
    # We don't have historical inventory tracking, so we will return 0.0% for inventory change, 
    # to do this properly we'd need a separate inventory snap-shot mechanism.
    inventory_value_change_str = "0.0%"

    # 3. Completed Orders count
    def get_completed_orders(start_date, end_date):
        return db.query(models.Order).filter(
            models.Order.warehouse_id == warehouse_id,
            models.Order.status == "completed",
            models.Order.order_date >= start_date,
            models.Order.order_date < end_date
        ).count()
        
    current_orders = get_completed_orders(current_month_start, now)
    previous_orders = get_completed_orders(previous_month_start, current_month_start)
    
    completed_orders = db.query(models.Order).filter(
        models.Order.warehouse_id == warehouse_id,
        models.Order.status == "completed"
    ).count()
    
    orders_change_pct = ((current_orders - previous_orders) / previous_orders * 100) if previous_orders > 0 else (100 if current_orders > 0 else 0)
    completed_orders_change_str = f"+{orders_change_pct:.1f}%" if orders_change_pct >= 0 else f"{orders_change_pct:.1f}%"

    # 4. Active Suppliers
    active_suppliers = db.query(models.Supplier).filter(
        models.Supplier.warehouse_id == warehouse_id,
        models.Supplier.status == 'active'
    ).count()
    active_suppliers_change_str = "0.0%"
    
    return {
        "total_revenue": revenue,
        "total_revenue_change": revenue_change_str,
        "inventory_value": inventory_value,
        "inventory_value_change": inventory_value_change_str,
        "completed_orders": completed_orders,
        "completed_orders_change": completed_orders_change_str,
        "active_suppliers": active_suppliers,
        "active_suppliers_change": active_suppliers_change_str
    }

@router.get("/revenue-trend")
def get_revenue_trend(context: dict = Depends(get_current_warehouse), db: Session = Depends(get_db)):
    warehouse_id = context["warehouse"].id
    
    labels = []
    data = []
    
    # Calculate revenue for the last 8 months 
    now = datetime.utcnow()
    for i in range(7, -1, -1):
        # Determine the target month and year
        month = now.month - i
        year = now.year
        while month <= 0:
            month += 12
            year -= 1
            
        start_date = now.replace(year=year, month=month, day=1, hour=0, minute=0, second=0, microsecond=0)
        
        if month == 12:
            end_date = start_date.replace(year=year+1, month=1)
        else:
            end_date = start_date.replace(month=month+1)
            
        revenue = db.query(func.sum(models.Order.total_value)).filter(
            models.Order.warehouse_id == warehouse_id,
            models.Order.order_type == "outbound",
            models.Order.status == "completed",
            models.Order.order_date >= start_date,
            models.Order.order_date < end_date
        ).scalar() or 0.0
        
        labels.append(calendar.month_abbr[month])
        data.append(revenue)
        
    return {
        "labels": labels,
        "data": data
    }

@router.get("/inventory-by-category")
def get_inventory_by_category(context: dict = Depends(get_current_warehouse), db: Session = Depends(get_db)):
    warehouse_id = context["warehouse"].id
    
    results = db.query(
        models.Product.category, 
        func.sum(models.Product.quantity).label('total')
    ).filter(
        models.Product.warehouse_id == warehouse_id
    ).group_by(models.Product.category).all()
    
    return [
        {"category": r[0] or 'Uncategorized', "value": r[1]} for r in results
    ]

@router.get("/low-stock-alerts")
def get_low_stock_alerts(context: dict = Depends(get_current_warehouse), db: Session = Depends(get_db)):
    warehouse_id = context["warehouse"].id
    
    low_stock_products = db.query(models.Product).filter(
        models.Product.warehouse_id == warehouse_id,
        models.Product.quantity < models.Product.min_stock
    ).all()
    
    return [
        {
            "id": p.id,
            "sku": p.sku,
            "name": p.name,
            "quantity": p.quantity,
            "min_stock": p.min_stock
        } for p in low_stock_products
    ]
