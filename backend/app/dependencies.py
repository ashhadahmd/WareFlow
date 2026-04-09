from fastapi import Depends, HTTPException, status, Header
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
import jwt

from app.database import get_db
from app.config import settings
from app.models import User, Warehouse, WarehouseMember, Permission, UserPermission

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


def get_current_user(
    token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)
):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except jwt.PyJWTError:
        raise credentials_exception

    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception
    return user


async def get_current_warehouse(
    x_warehouse_id: int = Header(..., description="Active Warehouse ID context"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    membership = (
        db.query(WarehouseMember)
        .filter(
            WarehouseMember.user_id == current_user.id,
            WarehouseMember.warehouse_id == x_warehouse_id,
        )
        .first()
    )

    if not membership:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have access to this warehouse or it doesn't exist.",
        )

    warehouse = db.query(Warehouse).filter(Warehouse.id == x_warehouse_id).first()
    return {"warehouse": warehouse, "role": membership.role, "user": current_user}


def require_permissions(required_permissions: list[str]):
    """
    Dependency factory that checks if the user has ALL required permissions
    in the context of the currently active warehouse.
    """

    async def permission_checker(
        warehouse_context: dict = Depends(get_current_warehouse),
        db: Session = Depends(get_db),
    ):
        role = warehouse_context["role"]
        user_id = warehouse_context["user"].id
        warehouse_id = warehouse_context["warehouse"].id

        if role in ["Owner", "Admin"]:
            return warehouse_context

        user_perms = (
            db.query(UserPermission)
            .join(Permission)
            .filter(
                UserPermission.user_id == user_id,
                UserPermission.warehouse_id == warehouse_id,
            )
            .all()
        )

        granted_perm_names = [up.permission.name for up in user_perms]

        for req_perm in required_permissions:
            if req_perm not in granted_perm_names:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"You do not have the necessary permission: {req_perm}",
                )
        return warehouse_context

    return permission_checker
