from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db
from ..dependencies import get_current_user


router = APIRouter(prefix="/inventory", tags=["inventory"])


@router.get("", response_model=list[schemas.IngredientOut])
def list_ingredients(
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    return db.query(models.Ingredient).order_by(models.Ingredient.name).all()


@router.get("/low-stock", response_model=list[schemas.IngredientOut])
def low_stock_ingredients(
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    return (
        db.query(models.Ingredient)
        .filter(models.Ingredient.current_stock <= models.Ingredient.minimum_stock)
        .order_by(models.Ingredient.name)
        .all()
    )


@router.post("", response_model=schemas.IngredientOut, status_code=201)
def create_ingredient(
    payload: schemas.IngredientCreate,
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    ingredient = models.Ingredient(**payload.model_dump())
    db.add(ingredient)
    db.commit()
    db.refresh(ingredient)
    return ingredient


@router.put("/{ingredient_id}", response_model=schemas.IngredientOut)
def update_ingredient(
    ingredient_id: int,
    payload: schemas.IngredientUpdate,
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    ingredient = db.get(models.Ingredient, ingredient_id)
    if not ingredient:
        raise HTTPException(status_code=404, detail="Ingrediente no encontrado.")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(ingredient, field, value)

    db.commit()
    db.refresh(ingredient)
    return ingredient
