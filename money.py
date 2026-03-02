from decimal import Decimal

from trytond.model import fields

from .utils import (
    calculate_percentage,
    evently_divide,
    evently_divide_portions,
    quantize_euros,
)


def Money(name, *args, **kwargs):
    return fields.Numeric(name, digits=(16, 2), *args, **kwargs)


def evently_divide_money(money, divisor_int):
    return evently_divide(money, divisor_int, Decimal("0.01"))


def evently_divide_portions_money(money, portions):
    return evently_divide_portions(money, portions, Decimal("0.01"))


def calculate_percentage_money(money, percentatge):
    return quantize_euros(calculate_percentage(money, percentatge))
