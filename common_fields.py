from trytond.model import fields
from trytond.pyson import And, Bool, Equal, Eval, Get, Greater, Not, Or

from .utils import get_or


def Company(name="Company", *args, **kwargs):
    return fields.Many2One("company.company", name, *args, **kwargs)


def Party(name="Party", *args, **kwargs):
    return fields.Many2One("party.party", name, *args, **kwargs)


def Weight(name="Weight Kg", *args, **kwargs):
    return fields.Numeric(name, (9, 3), *args, **kwargs)


def Volume(name="Volume m3", *args, **kwargs):
    return fields.Numeric(name, (9, 3), *args, **kwargs)


def add_state_key(field, key, statement):
    states = field.states or {}
    current_statement = get_or(states, key, None)
    states[key] = Or(statement, current_statement) if current_statement else statement
    field.states = states
    return field


def add_readonly(field, readonly):
    return add_state_key(field, "readonly", readonly)


def add_invisible(field, invisible):
    return add_state_key(field, "invisible", invisible)


def add_depends(field, depends):
    current_depends = field.depends or set()
    field.depends = current_depends.union(set(depends))
    return field


def readonly_no_company(field):v
    return add_depends(
        add_readonly(
            field,
            And(
                Bool(Eval("company")),
                Not(Equal(Eval("company"), Get(Eval("context", {}), "company", "0"))),
            ),
        ),
        ["company"],
    )


def invisible_no_company(field):
    return add_depends(
        add_invisible(
            field,
            Not(
                And(
                    Bool(Eval("company")),
                    Equal(Eval("company"), Get(Eval("context", {}), "company", "0")),
                )
            ),
        ),
        ["company"],
    )


def immutable(field):
    return add_depends(add_readonly(field, Greater(Eval("id", -1), 0)), ["id"])


def invisible_new(field):
    return add_depends(add_invisible(field, ~Greater(Eval("id", 0), 0)), ["id"])
