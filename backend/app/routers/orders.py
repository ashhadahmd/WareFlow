from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from datetime import datetime
from typing import List, Optional

from app import schemas, models
from app.database import get_db
from app.dependencies import get_current_warehouse, require_permissions

router = APIRouter(prefix="/orders", tags=["orders"])

def generate_order_number(db: Session, warehouse_id: int):
    year = datetime.now().year
    
    # Simple sequence generator: count orders for this year in this warehouse
    count = db.query(models.Order).filter(
        models.Order.warehouse_id == warehouse_id,
        models.Order.order_number.like(f"ORD-{year}-%")
    ).count()
    
    sequence = count + 1
    return f"ORD-{year}-{sequence:03d}"

@router.get("/", response_model=List[schemas.OrderResponse])
def get_orders(
    type: Optional[str] = None,
    status: Optional[str] = None,
    context: dict = Depends(get_current_warehouse),
    db: Session = Depends(get_db)
):
    warehouse_id = context["warehouse"].id
    query = db.query(models.Order).filter(models.Order.warehouse_id == warehouse_id)
    
    if type:
        query = query.filter(models.Order.order_type == type)
    if status:
        query = query.filter(models.Order.status == status)
        
    return query.all()

@router.post("/", response_model=schemas.OrderResponse)
def create_order(
    order: schemas.OrderCreate,
    context: dict = Depends(require_permissions(["orders:manage"])),
    db: Session = Depends(get_db)
):
    warehouse_id = context["warehouse"].id
    
    order_num = generate_order_number(db, warehouse_id)
    
    new_order = models.Order(
        order_number=order_num,
        order_type=order.order_type,
        supplier_id=order.supplier_id,
        status=order.status,
        notes=order.notes,
        warehouse_id=warehouse_id,
        total_value=0 # Will calculate from items
    )
    db.add(new_order)
    db.flush() # flush to get new_order.id
    
    total = 0.0
    for item in order.items:
        product = db.query(models.Product).filter(
            models.Product.id == item.product_id,
            models.Product.warehouse_id == warehouse_id
        ).first()
        
        if not product:
             raise HTTPException(status_code=400, detail=f"Product {item.product_id} not found in this warehouse")
             
        price = item.price_at_time if item.price_at_time is not None else product.price
             
        order_item = models.OrderItem(
            order_id=new_order.id,
            product_id=product.id,
            quantity=item.quantity,
            price_at_time=price
        )
        db.add(order_item)
        total += (price * item.quantity)
        
    new_order.total_value = total
    db.commit()
    db.refresh(new_order)
    return new_order

@router.get("/{order_id}", response_model=schemas.OrderResponse)
def get_order(order_id: int, context: dict = Depends(get_current_warehouse), db: Session = Depends(get_db)):
    order = db.query(models.Order).filter(
        models.Order.id == order_id,
        models.Order.warehouse_id == context["warehouse"].id
    ).first()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order

@router.patch("/{order_id}/status", response_model=schemas.OrderResponse)
def update_order_status(
    order_id: int,
    status_update: schemas.OrderUpdateStatus,
    context: dict = Depends(require_permissions(["orders:manage"])),
    db: Session = Depends(get_db)
):
    warehouse_id = context["warehouse"].id
    order = db.query(models.Order).filter(
        models.Order.id == order_id,
        models.Order.warehouse_id == warehouse_id
    ).first()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
        
    # Handle inventory logic on completion
    if order.status != "completed" and status_update.status == "completed":
        for item in order.items:
            product = db.query(models.Product).filter(models.Product.id == item.product_id).first()
            if order.order_type == "inbound":
                product.quantity += item.quantity
            elif order.order_type == "outbound":
                if product.quantity < item.quantity:
                    raise HTTPException(status_code=400, detail=f"Not enough stock for {product.name} (Has {product.quantity}, needed {item.quantity})")
                product.quantity -= item.quantity
                
    order.status = status_update.status
    db.commit()
    db.refresh(order)
    return order

@router.delete("/{order_id}")
def delete_order(
    order_id: int, 
    context: dict = Depends(require_permissions(["orders:manage"])), 
    db: Session = Depends(get_db)
):
    warehouse_id = context["warehouse"].id
    order = db.query(models.Order).filter(
        models.Order.id == order_id,
        models.Order.warehouse_id == warehouse_id
    ).first()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
        
    db.delete(order)
    db.commit()
    return {"message": "Order deleted successfully"}
