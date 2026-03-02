import datetime
import time
from datetime import timedelta

import pytz
from trytond.model import Model, fields
from trytond.pool import Pool

from .context import context_company, context_language, context_locale
from .utils import first

TIMEZONES = [(x, x) for x in pytz.common_timezones]


def timezones():
    return TIMEZONES


def default_timezone():
    return "Europe/Madrid"


def default_timezone_company_context():
    company_id = context_company()
    if company_id and company_id > 0:
        company = Pool().get("company.company")(company_id)
        if company and company.timezone:
            return company.timezone
    return default_timezone()


def date_today():
    date_model = Pool().get("ir.date")
    return date_model.today()


def datetime_now():
    return datetime.datetime.now()


def datetime_at(dt, h, m, s):
    return dt.replace(hour=h, minute=m, second=s)


def datetime_tomorrow_at(h, m, s):
    return plus_days(datetime_now(), 1).replace(hour=h, minute=m, second=s)


def date_first_day_month(date):
    return date.replace(day=1)


def date_last_day_month(date):
    month = date.month
    if date.month == 12:
        return date.replace(day=31)
    return (date_first_day_month(date).replace(month=month + 1) - timedelta(days=1))


def date_first_day_year(date):
    return date.replace(day=1).replace(month=1)


def date_first_day_current_year():
    return datetime.date.today().replace(day=1).replace(month=1)


def plus_days(dt_time, days):
    return dt_time + timedelta(days=days)


def next_day(dt_time):
    return plus_days(dt_time, 1)


def skip_weekend(dt_time):
    wkday = dt_time.weekday()
    if wkday == 5 or wkday == 6:
        return skip_weekend(next_day(dt_time))
    return dt_time


def plus_days_weekday(dt_time, days):
    return skip_weekend(plus_days(dt_time, days))


class DateBoundMixin(Model):
    start_date = fields.Date("Start Date", required=True)
    end_date = fields.Date("End Date")


def date_next_weekday(date, weekday):
    day_gap = int(weekday) - date.weekday()
    forward_day_gap = day_gap + 7 if 0 > day_gap else day_gap
    return date + timedelta(days=forward_day_gap)


def date_next_day_of_month(date, day_of_month):
    if date.day <= day_of_month:
        return date.replace(day=day_of_month)
    return date_next_day_of_month(plus_days(date_last_day_month(date), 1), day_of_month)


def dt_str4bots(sep="-"):
    return datetime.datetime.now().strftime("%Y%m%d%H%M%S") + sep + str(int(time.time()))


def format_dd_mmm_yy_hh_mm_context_tz_lang(dt):
    lang_model = Pool().get("ir.lang")
    lang = lang_model.get(context_language())
    return lang.strftime(
        dt.astimezone(pytz.timezone(default_timezone_company_context())),
        format="%d %b %y %H:%M",
    )


class DTMix(Model):
    dt = fields.Function(fields.Char("Datetime"), "get_dt")

    def get_dt(self, name=None):
        return format_dd_mmm_yy_hh_mm_context_tz_lang(self.create_date)

    @staticmethod
    def order_dt(tables):
        table = first(tables.get(None))
        return [table.create_date]
