from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import uuid

from app import schemas, models
from app.database import get_db
from app.dependencies import get_current_user, get_current_warehouse, require_permissions

router = APIRouter(prefix="/warehouses", tags=["warehouses"])

@router.post("/", response_model=schemas.WarehouseResponse)
def create_warehouse(warehouse: schemas.WarehouseCreate, current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    # Create the warehouse
    new_warehouse = models.Warehouse(name=warehouse.name)
    db.add(new_warehouse)
    db.commit()
    db.refresh(new_warehouse)
    
    # Make the creator the Owner
    member = models.WarehouseMember(
        user_id=current_user.id,
        warehouse_id=new_warehouse.id,
        role="Owner"
    )
    db.add(member)
    db.commit()
    
    return new_warehouse

@router.get("/", response_model=List[schemas.WarehouseResponse])
def list_my_warehouses(current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    # Get all warehouses this user is a member of
    memberships = db.query(models.WarehouseMember).filter(models.WarehouseMember.user_id == current_user.id).all()
    warehouse_ids = [m.warehouse_id for m in memberships]
    
    warehouses = db.query(models.Warehouse).filter(models.Warehouse.id.in_(warehouse_ids)).all()
    return warehouses

# --- Members and Permissions Management --- 

@router.get("/{warehouse_id}/me", response_model=schemas.WarehouseMemberResponse)
def get_my_membership(
    warehouse_id: int, 
    context: dict = Depends(get_current_warehouse), 
    db: Session = Depends(get_db)
):
    if context["warehouse"].id != warehouse_id:
        raise HTTPException(status_code=400, detail="Mismatched warehouse context")
        
    user = context["user"]
    member = db.query(models.WarehouseMember).filter(
        models.WarehouseMember.user_id == user.id,
        models.WarehouseMember.warehouse_id == warehouse_id
    ).first()
    
    if not member:
        raise HTTPException(status_code=404, detail="Membership not found")
        
    member.user = user
    user_perms = db.query(models.UserPermission).filter(
        models.UserPermission.user_id == user.id,
        models.UserPermission.warehouse_id == warehouse_id
    ).all()
    member.permissions = [up.permission for up in user_perms]
    
    return member

# (Requires 'users:manage' or Admin/Owner role)
@router.get("/{warehouse_id}/members", response_model=List[schemas.WarehouseMemberResponse])
def list_members(
    warehouse_id: int, 
    context: dict = Depends(require_permissions(["users:manage"])), 
    db: Session = Depends(get_db)
):
    if context["warehouse"].id != warehouse_id:
        raise HTTPException(status_code=400, detail="Mismatched warehouse context")
        
    members = db.query(models.WarehouseMember).filter(models.WarehouseMember.warehouse_id == warehouse_id).all()
    
    # Attach computed permissions to each member object for the response
    for member in members:
        # Load the user object explicitly if relationship lazy loading needs help
        user = db.query(models.User).filter(models.User.id == member.user_id).first()
        member.user = user
        
        user_perms = db.query(models.UserPermission).filter(
            models.UserPermission.user_id == member.user_id,
            models.UserPermission.warehouse_id == warehouse_id
        ).all()
        member.permissions = [up.permission for up in user_perms]
        
    return members

@router.post("/{warehouse_id}/members", response_model=schemas.WarehouseMemberResponse)
def add_member(
    warehouse_id: int,
    member_data: schemas.WarehouseMemberCreate,
    context: dict = Depends(require_permissions(["users:manage"])),
    db: Session = Depends(get_db)
):
    if context["warehouse"].id != warehouse_id:
        raise HTTPException(status_code=400, detail="Mismatched warehouse context")
        
    user = db.query(models.User).filter(models.User.email == member_data.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    existing = db.query(models.WarehouseMember).filter(
        models.WarehouseMember.user_id == user.id,
        models.WarehouseMember.warehouse_id == warehouse_id
    ).first()
    
    if existing:
        raise HTTPException(status_code=400, detail="User is already a member")
        
    new_member = models.WarehouseMember(
        user_id=user.id,
        warehouse_id=warehouse_id,
        role=member_data.role
    )
    db.add(new_member)
    db.commit()
    db.refresh(new_member)
    
    new_member.user = user
    new_member.permissions = []
    
    return new_member

# --- Email Invitation Endpoints ---

@router.post("/{warehouse_id}/invitations", response_model=schemas.WarehouseInvitationResponse)
def create_invitation(
    warehouse_id: int,
    invite_data: schemas.WarehouseInvitationCreate,
    context: dict = Depends(require_permissions(["users:manage"])),
    db: Session = Depends(get_db)
):
    if context["warehouse"].id != warehouse_id:
        raise HTTPException(status_code=400, detail="Mismatched warehouse context")
        
    # Check if the user is already a member
    user = db.query(models.User).filter(models.User.email == invite_data.email).first()
    if user:
        existing_member = db.query(models.WarehouseMember).filter(
            models.WarehouseMember.user_id == user.id,
            models.WarehouseMember.warehouse_id == warehouse_id
        ).first()
        if existing_member:
            raise HTTPException(status_code=400, detail="User is already a member of this warehouse")

    # Check if a pending invitation already exists for this email
    existing_invite = db.query(models.WarehouseInvitation).filter(
        models.WarehouseInvitation.email == invite_data.email,
        models.WarehouseInvitation.warehouse_id == warehouse_id,
        models.WarehouseInvitation.status == "pending"
    ).first()
    
    if existing_invite:
        # Just return the existing one so they can copy the link again
        return existing_invite

    # Create new invitation
    token = str(uuid.uuid4())
    new_invite = models.WarehouseInvitation(
        email=invite_data.email,
        token=token,
        role=invite_data.role,
        warehouse_id=warehouse_id,
        status="pending"
    )
    
    db.add(new_invite)
    db.commit()
    db.refresh(new_invite)
    
    return new_invite

@router.get("/invitation/{token}", response_model=schemas.WarehouseInvitationResponse)
def get_invitation_by_token(token: str, db: Session = Depends(get_db)):
    # This endpoint is public (no authentication needed) so the frontend can display the invite details
    invite = db.query(models.WarehouseInvitation).filter(
        models.WarehouseInvitation.token == token,
        models.WarehouseInvitation.status == "pending"
    ).first()
    
    if not invite:
        raise HTTPException(status_code=404, detail="Invitation not found, or it has already been accepted.")
        
    return invite

@router.post("/invitation/{token}/accept")
def accept_invitation(
    token: str, 
    current_user: models.User = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    # Find the pending invite
    invite = db.query(models.WarehouseInvitation).filter(
        models.WarehouseInvitation.token == token,
        models.WarehouseInvitation.status == "pending"
    ).first()
    
    if not invite:
        raise HTTPException(status_code=404, detail="Invitation not found or already accepted.")
        
    # Verify the email matches the current authenticated user
    if invite.email.lower() != current_user.email.lower():
        raise HTTPException(status_code=403, detail="This invitation was sent to a different email address.")
        
    # Check if they are already in the warehouse
    existing_member = db.query(models.WarehouseMember).filter(
        models.WarehouseMember.user_id == current_user.id,
        models.WarehouseMember.warehouse_id == invite.warehouse_id
    ).first()
    
    if existing_member:
        # Just mark the invite as accepted if somehow they got in already
        invite.status = "accepted"
        db.commit()
        return {"message": "You are already a member of this warehouse."}
        
    # Add them to the warehouse
    new_member = models.WarehouseMember(
        user_id=current_user.id,
        warehouse_id=invite.warehouse_id,
        role=invite.role
    )
    db.add(new_member)
    
    # Update invitation status
    invite.status = "accepted"
    
    db.commit()
    
    return {"message": "Invitation accepted successfully", "warehouse_id": invite.warehouse_id}

@router.put("/{warehouse_id}/members/{user_id}", response_model=schemas.WarehouseMemberResponse)
def update_member_permissions(
    warehouse_id: int,
    user_id: int,
    update_data: schemas.UpdateMemberPermissions,
    context: dict = Depends(require_permissions(["users:manage"])),
    db: Session = Depends(get_db)
):
    if context["warehouse"].id != warehouse_id:
        raise HTTPException(status_code=400, detail="Mismatched warehouse context")
        
    member = db.query(models.WarehouseMember).filter(
        models.WarehouseMember.user_id == user_id,
        models.WarehouseMember.warehouse_id == warehouse_id
    ).first()
    
    if not member:
        raise HTTPException(status_code=404, detail="Member not found")
        
    # Update Role
    member.role = update_data.role
    
    # Update specific permissions
    # 1. Clear existing
    db.query(models.UserPermission).filter(
        models.UserPermission.user_id == user_id,
        models.UserPermission.warehouse_id == warehouse_id
    ).delete()
    
    # 2. Add new
    added_perms = []
    for perm_name in update_data.permissions:
        permission = db.query(models.Permission).filter(models.Permission.name == perm_name).first()
        if permission:
            new_up = models.UserPermission(
                user_id=user_id,
                warehouse_id=warehouse_id,
                permission_id=permission.id
            )
            db.add(new_up)
            added_perms.append(permission)
            
    db.commit()
    db.refresh(member)
    member.user = db.query(models.User).filter(models.User.id == user_id).first()
    member.permissions = added_perms
    
    return member

@router.delete("/{warehouse_id}/members/{user_id}")
def remove_member(
    warehouse_id: int,
    user_id: int,
    context: dict = Depends(require_permissions(["users:manage"])),
    db: Session = Depends(get_db)
):
    if context["warehouse"].id != warehouse_id:
        raise HTTPException(status_code=400, detail="Mismatched warehouse context")
        
    member = db.query(models.WarehouseMember).filter(
        models.WarehouseMember.user_id == user_id,
        models.WarehouseMember.warehouse_id == warehouse_id
    ).first()
    
    if not member:
        raise HTTPException(status_code=404, detail="Member not found")
        
    if member.role == "Owner":
         raise HTTPException(status_code=400, detail="Cannot remove the Owner")
         
    # Cleanup permissions
    db.query(models.UserPermission).filter(
        models.UserPermission.user_id == user_id,
        models.UserPermission.warehouse_id == warehouse_id
    ).delete()
    
    db.delete(member)
    db.commit()
    return {"message": "Member removed"}
