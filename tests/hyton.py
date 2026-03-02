import datetime
from decimal import Decimal
from itertools import groupby

from trytond import pyson
from trytond.pool import Pool
from trytond.tests.test_tryton import ModuleTestCase, with_transaction

from trytond.modules.hyton import common_fields
from trytond.modules.hyton.date import date_last_day_month, date_next_weekday
from trytond.modules.hyton.sugar import gets
from trytond.modules.hyton.utils import (
    c_group_by,
    evently_divide,
    evently_divide_portions,
    is_str_empty,
    is_str_not_empty,
    volume_cms_to_m3,
    volume_m3_fix_long_to_cms,
    volume_m3_to_cms,
)


def is_even(x):
    return x % 2 == 0


class HytonTestCase(ModuleTestCase):
    "Test Hyton"

    module = "hyton"

    @with_transaction()
    def test_gets(self):
        [user] = gets(Pool(), ["res.user"])
        self.assertEqual(1, 1)

    @with_transaction()
    def test_next_day_of_week(self):
        self.assertEqual(
            date_next_weekday(datetime.date(2021, 2, 1), 4),
            datetime.date(2021, 2, 5),
        )
        self.assertEqual(
            date_next_weekday(datetime.date(2021, 2, 1), "4"),
            datetime.date(2021, 2, 5),
        )
        self.assertEqual(
            date_next_weekday(datetime.date(2021, 2, 6), "4"),
            datetime.date(2021, 2, 12),
        )
        self.assertEqual(datetime.date(2021, 2, 12).weekday(), 4)
        self.assertEqual(
            date_next_weekday(datetime.date(2021, 2, 1), 0),
            datetime.date(2021, 2, 1),
        )

    @with_transaction()
    def test_last_day_month_2021_1_29_fix(self):
        self.assertEqual(
            date_last_day_month(datetime.date(2021, 1, 29)),
            datetime.date(2021, 1, 31),
        )

    @with_transaction()
    def test_add_depends(self):
        self.assertEqual(common_fields.Company().depends, set())
        self.assertEqual(
            common_fields.add_depends(common_fields.Company(), ["hola"]).depends,
            {"hola"},
        )
        self.assertEqual(
            sorted(
                common_fields.add_depends(
                    common_fields.Company(depends=["hola", "adeu"]),
                    {"hola", "goodbye"},
                ).depends
            ),
            sorted(["hola", "adeu", "goodbye"]),
        )

    @with_transaction()
    def test_add_readonly(self):
        self.assertEqual(common_fields.Company().states, {}, "no state")
        self.assertEqual(
            common_fields.add_readonly(common_fields.Company(), True).states,
            {"readonly": True},
        )
        self.assertEqual(
            common_fields.add_readonly(
                common_fields.Company(states={"readonly": True}),
                True,
            ).states,
            {"readonly": pyson.And(True, True)},
        )

    def test_str_empty(self):
        self.assertTrue(is_str_empty(None))
        self.assertTrue(is_str_empty(""))
        self.assertTrue(is_str_empty("  "))
        self.assertFalse(is_str_not_empty("  "))
        self.assertTrue(is_str_not_empty(" h "))

    def test_c_group_by(self):
        self.assertEqual(len(list(groupby([1, 2, 3, 4], is_even))), 4)
        self.assertEqual(len(list(c_group_by(is_even, [1, 2, 3, 4]))), 2)

    def test_evently_divide(self):
        self.assertEqual(
            evently_divide(Decimal("0.11"), 2, Decimal("0.01")),
            [Decimal("0.06"), Decimal("0.05")],
        )
        self.assertEqual(
            evently_divide(Decimal("0.11"), 3, Decimal("0.01")),
            [Decimal("0.04"), Decimal("0.04"), Decimal("0.03")],
        )
        self.assertEqual(
            evently_divide(Decimal("-0.11"), 3, Decimal("0.01")),
            [Decimal("-0.04"), Decimal("-0.04"), Decimal("-0.03")],
        )
        self.assertEqual(
            evently_divide(Decimal("-0"), 3, Decimal("0.01")),
            [Decimal("0.00"), Decimal("0.00"), Decimal("0.00")],
        )

    def test_volume_to_cms(self):
        self.assertEqual(volume_m3_to_cms(Decimal("1")), [100, 100, 100])
        self.assertEqual(
            volume_m3_fix_long_to_cms(Decimal("1"), Decimal("200")),
            [Decimal("200"), Decimal("70.71"), Decimal("70.71")],
        )
        self.assertEqual(
            volume_cms_to_m3([Decimal("200"), Decimal("70.71"), Decimal("70.71")]),
            1,
        )

    def test_evently_divide_portions(self):
        self.assertEqual(
            evently_divide_portions(
                Decimal("0.10"), [Decimal("4"), Decimal("6")], Decimal("0.01")
            ),
            [Decimal("0.04"), Decimal("0.06")],
        )
        self.assertEqual(
            evently_divide_portions(
                Decimal("0.11"), [Decimal("1"), Decimal("1")], Decimal("0.01")
            ),
            [Decimal("0.06"), Decimal("0.05")],
        )
        self.assertEqual(
            evently_divide_portions(
                Decimal("-0.10"), [Decimal("4"), Decimal("6")], Decimal("0.01")
            ),
            [Decimal("-0.04"), Decimal("-0.06")],
        )
        self.assertEqual(
            evently_divide_portions(
                Decimal("-0.11"), [Decimal("1"), Decimal("1")], Decimal("0.01")
            ),
            [Decimal("-0.06"), Decimal("-0.05")],
        )
        self.assertEqual(
            evently_divide_portions(
                Decimal("-0.11"), [Decimal("1"), Decimal("0")], Decimal("0.01")
            ),
            [Decimal("-0.11"), Decimal("0")],
        )
