from datetime import datetime
from decimal import Decimal
from typing import Literal

from pydantic import BaseModel, EmailStr, Field, field_validator


Role = Literal["admin", "encargado", "vendedor", "cliente"]
OrderStatus = Literal["pendiente", "pagado", "entregado", "cancelado"]


class LoginIn(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=72)


class UserBase(BaseModel):
    name: str = Field(min_length=3, max_length=120)
    email: EmailStr
    role: Role = "vendedor"
    is_active: bool = True


class UserCreate(UserBase):
    password: str = Field(min_length=8, max_length=72)

    @field_validator("password")
    @classmethod
    def password_strength(cls, value: str) -> str:
        if not any(char.isdigit() for char in value):
            raise ValueError("La contrasena debe incluir al menos un numero.")
        if not any(char.isupper() for char in value):
            raise ValueError("La contrasena debe incluir al menos una mayuscula.")
        return value


class UserUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=3, max_length=120)
    email: EmailStr | None = None
    role: Role | None = None
    is_active: bool | None = None
    password: str | None = Field(default=None, min_length=8, max_length=72)


class UserOut(UserBase):
    id: int
    created_at: datetime

    model_config = {"from_attributes": True}


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut


class ProductBase(BaseModel):
    name: str = Field(min_length=2, max_length=140)
    category: str = Field(min_length=2, max_length=80)
    price: Decimal = Field(gt=0, max_digits=10, decimal_places=2)
    stock: int = Field(ge=0)
    description: str | None = Field(default=None, max_length=600)
    is_active: bool = True


class ProductCreate(ProductBase):
    pass


class ProductUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=140)
    category: str | None = Field(default=None, min_length=2, max_length=80)
    price: Decimal | None = Field(default=None, gt=0, max_digits=10, decimal_places=2)
    stock: int | None = Field(default=None, ge=0)
    description: str | None = Field(default=None, max_length=600)
    is_active: bool | None = None


class ProductOut(ProductBase):
    id: int

    model_config = {"from_attributes": True}


class IngredientBase(BaseModel):
    name: str = Field(min_length=2, max_length=140)
    unit: str = Field(min_length=1, max_length=30)
    minimum_stock: Decimal = Field(ge=0, max_digits=10, decimal_places=2)
    current_stock: Decimal = Field(ge=0, max_digits=10, decimal_places=2)


class IngredientCreate(IngredientBase):
    pass


class IngredientUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=140)
    unit: str | None = Field(default=None, min_length=1, max_length=30)
    minimum_stock: Decimal | None = Field(default=None, ge=0, max_digits=10, decimal_places=2)
    current_stock: Decimal | None = Field(default=None, ge=0, max_digits=10, decimal_places=2)


class IngredientOut(IngredientBase):
    id: int

    model_config = {"from_attributes": True}


class OrderItemCreate(BaseModel):
    product_id: int = Field(gt=0)
    quantity: int = Field(gt=0, le=500)


class OrderItemOut(BaseModel):
    id: int
    product_id: int
    quantity: int
    unit_price: Decimal
    subtotal: Decimal

    model_config = {"from_attributes": True}


class OrderCreate(BaseModel):
    customer_name: str | None = Field(default=None, min_length=3, max_length=140)
    items: list[OrderItemCreate] = Field(min_length=1)


class OrderUpdate(BaseModel):
    customer_name: str | None = Field(default=None, min_length=3, max_length=140)
    status: OrderStatus | None = None


class OrderOut(BaseModel):
    id: int
    user_id: int | None = None
    customer_name: str
    status: str
    total: Decimal
    created_at: datetime
    items: list[OrderItemOut]

    model_config = {"from_attributes": True}


class ReportOut(BaseModel):
    products: int
    active_users: int
    orders: int
    sales_total: Decimal
    low_stock_ingredients: int
