from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, selectinload

from .. import models, schemas
from ..database import get_db
from ..dependencies import get_current_user


router = APIRouter(prefix="/orders", tags=["orders"])


@router.get("", response_model=list[schemas.OrderOut])
def list_orders(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    query = db.query(models.Order).options(selectinload(models.Order.items))
    if current_user.role == "cliente":
        query = query.filter(models.Order.user_id == current_user.id)
    return query.order_by(models.Order.created_at.desc()).all()


@router.post("", response_model=schemas.OrderOut, status_code=201)
def create_order(
    payload: schemas.OrderCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    customer_name = payload.customer_name or current_user.name
    order = models.Order(
        customer_name=customer_name,
        user_id=current_user.id if current_user.role == "cliente" else None,
    )
    total = Decimal("0.00")

    for item_payload in payload.items:
        product = db.get(models.Product, item_payload.product_id)
        if not product or not product.is_active:
            raise HTTPException(status_code=404, detail="Producto no disponible.")
        if product.stock < item_payload.quantity:
            raise HTTPException(
                status_code=400,
                detail=f"Stock insuficiente para {product.name}.",
            )

        subtotal = product.price * item_payload.quantity
        product.stock -= item_payload.quantity
        total += subtotal
        order.items.append(
            models.OrderItem(
                product_id=product.id,
                quantity=item_payload.quantity,
                unit_price=product.price,
                subtotal=subtotal,
            )
        )

    order.total = total
    db.add(order)
    db.commit()
    db.refresh(order)
    return order


@router.put("/{order_id}", response_model=schemas.OrderOut)
def update_order(
    order_id: int,
    payload: schemas.OrderUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    order = db.get(models.Order, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Pedido no encontrado.")
    if current_user.role == "cliente":
        raise HTTPException(status_code=403, detail="Los clientes no pueden editar pedidos.")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(order, field, value)

    db.commit()
    db.refresh(order)
    return order
