from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# --- Token Schemas ---
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

# --- User Schemas ---
class UserBase(BaseModel):
    email: EmailStr
    name: Optional[str] = None

class UserCreate(UserBase):
    password: str

class UserResponse(UserBase):
    id: int
    is_active: bool

    model_config = {"from_attributes": True}

# --- Warehouse Schemas ---
class WarehouseBase(BaseModel):
    name: str

class WarehouseCreate(WarehouseBase):
    pass

class WarehouseResponse(WarehouseBase):
    id: int
    created_at: datetime

    model_config = {"from_attributes": True}

# --- Warehouse Member & Permission Schemas ---
class WarehouseMemberCreate(BaseModel):
    email: EmailStr
    role: str

class WarehouseInvitationCreate(BaseModel):
    email: EmailStr
    role: str

class WarehouseInvitationResponse(BaseModel):
    id: int
    email: str
    token: str
    role: str
    warehouse_id: int
    created_at: datetime
    status: str

    model_config = {"from_attributes": True}

class PermissionResponse(BaseModel):
    id: int
    name: str
    description: Optional[str] = None

    model_config = {"from_attributes": True}

class WarehouseMemberResponse(BaseModel):
    id: int
    user_id: int
    warehouse_id: int
    role: str
    joined_at: datetime
    user: UserResponse
    permissions: List[PermissionResponse] = [] # Calculated at runtime

    model_config = {"from_attributes": True}

class UpdateMemberPermissions(BaseModel):
    role: str
    permissions: List[str] # List of permission names like "inventory:write"

# --- Common Warehouse Context ---
class WarehouseContextIn(BaseModel):
    warehouse_id: int
