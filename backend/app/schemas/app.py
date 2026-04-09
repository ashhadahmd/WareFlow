from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

# --- Product Schemas ---
class ProductBase(BaseModel):
    sku: str
    name: str
    category: Optional[str] = None
    quantity: int = 0
    min_stock: int = 0
    price: float = 0.0
    location: Optional[str] = None
    supplier_id: Optional[int] = None

class ProductCreate(ProductBase):
    pass

class ProductUpdate(ProductBase):
    sku: Optional[str] = None
    name: Optional[str] = None

class ProductResponse(ProductBase):
    id: int
    warehouse_id: int

    model_config = {"from_attributes": True}

# --- Supplier Schemas ---
class SupplierBase(BaseModel):
    name: str
    contact_name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    status: str = "active"
    rating: float = 0.0

class SupplierCreate(SupplierBase):
    pass

class SupplierUpdate(SupplierBase):
    name: Optional[str] = None

class SupplierResponse(SupplierBase):
    id: int
    warehouse_id: int

    model_config = {"from_attributes": True}

# --- Order Item Schemas ---
class OrderItemCreate(BaseModel):
    product_id: int
    quantity: int
    price_at_time: Optional[float] = None # Can be inferred from product

class OrderItemResponse(BaseModel):
    id: int
    product_id: int
    quantity: int
    price_at_time: float

    model_config = {"from_attributes": True}

# --- Order Schemas ---
class OrderBase(BaseModel):
    order_type: str # "inbound" or "outbound"
    supplier_id: Optional[int] = None
    total_value: float = 0.0
    status: str = "pending"
    notes: Optional[str] = None

class OrderCreate(OrderBase):
    items: List[OrderItemCreate]

class OrderUpdateStatus(BaseModel):
    status: str

class OrderResponse(OrderBase):
    id: int
    order_number: str
    order_date: datetime
    warehouse_id: int
    items: List[OrderItemResponse] = []

    model_config = {"from_attributes": True}
