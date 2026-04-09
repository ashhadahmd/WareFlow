from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Float, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    name = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)

    warehouse_memberships = relationship("WarehouseMember", back_populates="user")
    user_permissions = relationship("UserPermission", back_populates="user")


class Warehouse(Base):
    __tablename__ = "warehouses"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    members = relationship(
        "WarehouseMember", back_populates="warehouse", cascade="all, delete-orphan"
    )
    products = relationship(
        "Product", back_populates="warehouse", cascade="all, delete-orphan"
    )
    suppliers = relationship(
        "Supplier", back_populates="warehouse", cascade="all, delete-orphan"
    )
    orders = relationship(
        "Order", back_populates="warehouse", cascade="all, delete-orphan"
    )
    user_permissions = relationship(
        "UserPermission", back_populates="warehouse", cascade="all, delete-orphan"
    )


class WarehouseMember(Base):
    __tablename__ = "warehouse_members"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    warehouse_id = Column(Integer, ForeignKey("warehouses.id"))
    role = Column(String, default="Member")  # "Owner", "Admin", "Member"
    joined_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="warehouse_memberships")
    warehouse = relationship("Warehouse", back_populates="members")


class WarehouseInvitation(Base):
    __tablename__ = "warehouse_invitations"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, index=True, nullable=False)
    token = Column(String, unique=True, index=True, nullable=False)
    role = Column(String, default="Member")
    warehouse_id = Column(Integer, ForeignKey("warehouses.id"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    status = Column(String, default="pending")  # "pending", "accepted"

    warehouse = relationship("Warehouse")


class Permission(Base):
    __tablename__ = "permissions"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(
        String, unique=True, index=True
    )  # e.g., "inventory:read", "inventory:write"
    description = Column(String, nullable=True)


class UserPermission(Base):
    __tablename__ = "user_permissions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    warehouse_id = Column(Integer, ForeignKey("warehouses.id"))
    permission_id = Column(Integer, ForeignKey("permissions.id"))

    user = relationship("User", back_populates="user_permissions")
    warehouse = relationship("Warehouse", back_populates="user_permissions")
    permission = relationship("Permission")


class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    sku = Column(String, index=True, nullable=False)
    name = Column(String, index=True, nullable=False)
    category = Column(String, index=True)
    quantity = Column(Integer, default=0)
    min_stock = Column(Integer, default=0)
    price = Column(Float, default=0.0)
    location = Column(String)
    supplier_id = Column(Integer, ForeignKey("suppliers.id"))
    warehouse_id = Column(Integer, ForeignKey("warehouses.id"))

    warehouse = relationship("Warehouse", back_populates="products")
    supplier = relationship("Supplier", back_populates="products")


class Supplier(Base):
    __tablename__ = "suppliers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, nullable=False)
    contact_name = Column(String)
    email = Column(String)
    phone = Column(String)
    address = Column(String)
    status = Column(String, default="active")  # active, inactive
    rating = Column(Float, default=0.0)
    warehouse_id = Column(Integer, ForeignKey("warehouses.id"))

    warehouse = relationship("Warehouse", back_populates="suppliers")
    products = relationship("Product", back_populates="supplier")
    orders = relationship("Order", back_populates="supplier")


class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    order_number = Column(String, index=True, nullable=False)
    order_type = Column(String)  # "inbound", "outbound"
    supplier_id = Column(Integer, ForeignKey("suppliers.id"))
    total_value = Column(Float, default=0.0)
    order_date = Column(DateTime(timezone=True), server_default=func.now())
    status = Column(
        String, default="pending"
    )  # pending, processing, completed, cancelled
    notes = Column(String, nullable=True)
    warehouse_id = Column(Integer, ForeignKey("warehouses.id"))

    warehouse = relationship("Warehouse", back_populates="orders")
    supplier = relationship("Supplier", back_populates="orders")
    items = relationship(
        "OrderItem", back_populates="order", cascade="all, delete-orphan"
    )


class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    product_id = Column(Integer, ForeignKey("products.id"))
    quantity = Column(Integer, nullable=False)
    price_at_time = Column(Float, nullable=False)

    order = relationship("Order", back_populates="items")
    product = relationship("Product")
