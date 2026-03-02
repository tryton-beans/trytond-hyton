from trytond.transaction import Transaction


def context_get(key):
    return Transaction().context.get(key)


def context_language():
    return Transaction().language


def context_company():
    return context_get("company")


def context_warehouse():
    return context_get("cargo_warehouse")


def context_locale():
    return context_get("locale")


def context_active_ids():
    return context_get("active_ids")


def context_date_format():
    locale = context_locale()
    if locale:
        return locale.get("date", "%Y-%m-%d")
    return "%Y-%m-%d"
