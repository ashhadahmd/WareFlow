from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from app import schemas, models
from app.database import get_db
from app.dependencies import get_current_warehouse, require_permissions

router = APIRouter(prefix="/inventory", tags=["inventory"])

@router.get("/", response_model=List[schemas.ProductResponse])
def get_inventory(
    search: Optional[str] = None,
    category: Optional[str] = None,
    context: dict = Depends(get_current_warehouse),
    db: Session = Depends(get_db)
):
    warehouse_id = context["warehouse"].id
    query = db.query(models.Product).filter(models.Product.warehouse_id == warehouse_id)
    
    if search:
        query = query.filter(
            (models.Product.name.ilike(f"%{search}%")) |
            (models.Product.sku.ilike(f"%{search}%"))
        )
    if category:
        query = query.filter(models.Product.category == category)
        
    return query.all()

@router.post("/", response_model=schemas.ProductResponse)
def create_product(
    product: schemas.ProductCreate,
    context: dict = Depends(require_permissions(["inventory:write"])),
    db: Session = Depends(get_db)
):
    warehouse_id = context["warehouse"].id
    
    # Check distinct SKU inside the same warehouse
    existing_sku = db.query(models.Product).filter(
        models.Product.sku == product.sku,
        models.Product.warehouse_id == warehouse_id
    ).first()
    
    if existing_sku:
        raise HTTPException(status_code=400, detail="SKU already exists in this warehouse")
        
    new_product = models.Product(**product.model_dump(), warehouse_id=warehouse_id)
    db.add(new_product)
    db.commit()
    db.refresh(new_product)
    return new_product

@router.get("/{product_id}", response_model=schemas.ProductResponse)
def get_product(product_id: int, context: dict = Depends(get_current_warehouse), db: Session = Depends(get_db)):
    product = db.query(models.Product).filter(
        models.Product.id == product_id,
        models.Product.warehouse_id == context["warehouse"].id
    ).first()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@router.put("/{product_id}", response_model=schemas.ProductResponse)
def update_product(
    product_id: int,
    product_in: schemas.ProductUpdate,
    context: dict = Depends(require_permissions(["inventory:write"])),
    db: Session = Depends(get_db)
):
    warehouse_id = context["warehouse"].id
    product = db.query(models.Product).filter(
        models.Product.id == product_id,
        models.Product.warehouse_id == warehouse_id
    ).first()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    update_data = product_in.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(product, key, value)
        
    db.commit()
    db.refresh(product)
    return product

@router.delete("/{product_id}")
def delete_product(
    product_id: int, 
    context: dict = Depends(require_permissions(["inventory:write"])), 
    db: Session = Depends(get_db)
):
    warehouse_id = context["warehouse"].id
    product = db.query(models.Product).filter(
        models.Product.id == product_id,
        models.Product.warehouse_id == warehouse_id
    ).first()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    db.delete(product)
    db.commit()
    return {"message": "Product deleted successfully"}
