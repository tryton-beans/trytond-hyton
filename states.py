from trytond.pyson import And, Bool, Equal, Eval, Get, Not


class NoCompanyStates:
    READONLY = {
        "readonly": And(
            Bool(Eval("company")),
            Not(Equal(Eval("company"), Get(Eval("context", dict()), "company", "0"))),
        )
    }
    INVISIBLE = {
        "invisible": Not(
            Equal(Eval("company"), Get(Eval("context", dict()), "company", "0"))
        )
    }
    DEPENDS = ["company"]
