import decimal
from decimal import Decimal
from functools import reduce
from itertools import repeat, groupby
from operator import add


def is_none(x):
    return x is None


def is_not_none(x):
    return not is_none(x)


def filter_none(lst):
    return filter(is_not_none, lst)


def is_empty(coll):
    return len(coll) == 0


def first(coll):
    return next(iter(coll), None)


def some(pred, coll):
    return first(filter(None, map(pred, coll)))


def quantize_euros(d):
    if not is_none(d):
        return d.quantize(decimal.Decimal("0.01"), decimal.ROUND_HALF_UP)
    return None


def calculate_percentage(percentage, value):
    return (value * percentage) / Decimal("100")


def get_or(map_obj, key, value):
    try:
        return map_obj[key]
    except KeyError:
        return value


def get_or_none(map_obj, key):
    return get_or(map_obj, key, None)


def is_str_empty(s):
    return is_none(s) or is_empty(s.strip())


def is_str_not_empty(s):
    return not is_str_empty(s)


def str_as_one_line(s):
    if s:
        return " ".join(s.split())
    return s


def strip_empty_return_none(s):
    if s:
        s_strip = s.strip()
        if not is_empty(s_strip):
            return s_strip
    return None


def less_caps(a_string):
    return " ".join(
        map(lambda s: s if s == s.lower() else s.capitalize(), a_string.split())
    )


def evently_divide(dividend_decimal, divisor_int, decimal_min_value):
    total_amount = abs(dividend_decimal).quantize(decimal_min_value)
    low_amount = (total_amount / divisor_int).quantize(
        decimal_min_value, decimal.ROUND_DOWN
    )
    high_amount = low_amount + decimal_min_value
    num_highs = int(total_amount * (1 / decimal_min_value)) % divisor_int
    num_lows = divisor_int - num_highs
    dividend_decimal_fn = (lambda x: x) if 0 < dividend_decimal else (lambda x: -x)
    high_amount = dividend_decimal_fn(high_amount)
    low_amount = dividend_decimal_fn(low_amount)
    return list(repeat(high_amount, num_highs)) + list(repeat(low_amount, num_lows))


def evently_divide_portions(value, portions, decimal_min_value):
    total_portions = reduce(add, portions)
    values = list(
        map(
            lambda portion: ((value * portion) / total_portions).quantize(
                decimal_min_value, decimal.ROUND_DOWN
            ),
            portions,
        )
    )
    diff = value - reduce(add, values)
    if diff == 0:
        return values
    return list(map(add, values, evently_divide(diff, len(values), decimal_min_value)))


def c_group_by(fn, iterable):
    return groupby(sorted(iterable, key=fn), key=fn)


def volume_m3_to_cms(volume_m3):
    if volume_m3 is not None and volume_m3 >= 0:
        return evently_divide(
            Decimal(300 * (float(volume_m3) ** (1 / 3))), 3, Decimal("0.01")
        )
    return None


def volume_m3_fix_long_to_cms(volume_m3, long_cm):
    if volume_m3 is not None and volume_m3 >= 0:
        return [long_cm] + evently_divide(
            Decimal(2000 * ((float(volume_m3) / float(long_cm)) ** (1 / 2))),
            2,
            Decimal("0.01"),
        )
    return None


def volume_cms_to_m3(cms):
    cm3 = reduce(lambda x, y: x * y, cms)
    return (
        (cm3 / Decimal("1000000")) if cm3 else cm3
    ).quantize(Decimal("0.001"), decimal.ROUND_HALF_UP)


def eliminate_duplicate_by_id(models):
    if models:
        return reduce(
            lambda acc, m: (
                acc.append(m)
                or acc
                if m and not some(lambda x: x.id == m.id, acc)
                else acc
            ),
            models,
            [],
        )
    return models
