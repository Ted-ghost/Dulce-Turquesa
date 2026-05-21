from decimal import Decimal

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db
from ..dependencies import get_current_user


router = APIRouter(prefix="/reports", tags=["reports"])


@router.get("/summary", response_model=schemas.ReportOut)
def summary(
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    sales_total = db.query(func.coalesce(func.sum(models.Order.total), 0)).scalar()
    low_stock = (
        db.query(models.Ingredient)
        .filter(models.Ingredient.current_stock <= models.Ingredient.minimum_stock)
        .count()
    )
    return {
        "products": db.query(models.Product).count(),
        "active_users": db.query(models.User).filter(models.User.is_active.is_(True)).count(),
        "orders": db.query(models.Order).count(),
        "sales_total": Decimal(sales_total or 0),
        "low_stock_ingredients": low_stock,
    }
