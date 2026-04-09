from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List

from app import schemas, models
from app.database import get_db
from app.dependencies import get_current_warehouse, require_permissions

router = APIRouter(prefix="/suppliers", tags=["suppliers"])

@router.get("/", response_model=List[schemas.SupplierResponse])
def get_suppliers(context: dict = Depends(get_current_warehouse), db: Session = Depends(get_db)):
    warehouse_id = context["warehouse"].id
    return db.query(models.Supplier).filter(models.Supplier.warehouse_id == warehouse_id).all()

@router.post("/", response_model=schemas.SupplierResponse)
def create_supplier(
    supplier: schemas.SupplierCreate, 
    context: dict = Depends(require_permissions(["suppliers:write"])), 
    db: Session = Depends(get_db)
):
    new_supplier = models.Supplier(**supplier.model_dump(), warehouse_id=context["warehouse"].id)
    db.add(new_supplier)
    db.commit()
    db.refresh(new_supplier)
    return new_supplier

@router.get("/{supplier_id}", response_model=schemas.SupplierResponse)
def get_supplier(supplier_id: int, context: dict = Depends(get_current_warehouse), db: Session = Depends(get_db)):
    supplier = db.query(models.Supplier).filter(
        models.Supplier.id == supplier_id,
        models.Supplier.warehouse_id == context["warehouse"].id
    ).first()
    if not supplier:
        raise HTTPException(status_code=404, detail="Supplier not found")
    return supplier

@router.put("/{supplier_id}", response_model=schemas.SupplierResponse)
def update_supplier(
    supplier_id: int, 
    supplier_in: schemas.SupplierUpdate, 
    context: dict = Depends(require_permissions(["suppliers:write"])), 
    db: Session = Depends(get_db)
):
    supplier = db.query(models.Supplier).filter(
        models.Supplier.id == supplier_id,
        models.Supplier.warehouse_id == context["warehouse"].id
    ).first()
    
    if not supplier:
        raise HTTPException(status_code=404, detail="Supplier not found")
        
    update_data = supplier_in.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(supplier, key, value)
        
    db.commit()
    db.refresh(supplier)
    return supplier

@router.delete("/{supplier_id}")
def delete_supplier(
    supplier_id: int, 
    context: dict = Depends(require_permissions(["suppliers:write"])), 
    db: Session = Depends(get_db)
):
    supplier = db.query(models.Supplier).filter(
        models.Supplier.id == supplier_id,
        models.Supplier.warehouse_id == context["warehouse"].id
    ).first()
    
    if not supplier:
        raise HTTPException(status_code=404, detail="Supplier not found")
        
    db.delete(supplier)
    db.commit()
    return {"message": "Supplier deleted successfully"}
