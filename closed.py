import inspect

from trytond.model import ModelSQL, fields
from trytond.model.fields import Field
from trytond.pyson import Equal, Eval

from .common_fields import add_depends, add_readonly

_close_readonly_statement = Equal(Eval("closed", False), True)


def readonly_closed_setup(klass):
    for _, member in inspect.getmembers(klass):
        if isinstance(member, Field):
            add_depends(add_readonly(member, _close_readonly_statement), ["closed"])


class Closeable(ModelSQL):
    closed = fields.Boolean("Closed", readonly=True)

    @classmethod
    def readonly_closed_setup(cls):
        for _, member in inspect.getmembers(cls):
            if isinstance(member, Field):
                add_depends(
                    add_readonly(member, _close_readonly_statement), ["closed"]
                )

    @classmethod
    def default_closed(cls):
        return False

    def can_close(self):
        return True

    def _close(self):
        if self.can_close():
            self.closed = True
            return True
        return None

    def can_open(self):
        return True

    def _open(self):
        if self.can_open():
            self.closed = False
            return True
        return None
