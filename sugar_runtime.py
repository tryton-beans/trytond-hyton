from functools import reduce

from cytoolz import partition, second
from hyrule import rest
from trytond.model import Index, Model, fields
from trytond.pool import Pool

from .context import context_active_ids
from .utils import first


def gets(provider, keys):
    return map(lambda s: provider.get(s), keys)


def save(model):
    model.save()
    return model


def save_all(models):
    if models:
        Pool().get(models[0].__name__).save(models)
    return models


def pool_gets(provider, keys):
    return map(lambda s: Pool().get(s), keys)


def pool_create(model_name, *args, **kwargs):
    return save(Pool().get(model_name)(*args, **kwargs))


def pool_new(model_name, *args, **kwargs):
    return Pool().get(model_name)(*args, **kwargs)


def pool_load(model_name, id_):
    return Pool().get(model_name)(id_)


def pool_search(model_name, *args, **kwargs):
    return Pool().get(model_name).search(*args, **kwargs)


def pool_delete(model_name, *args, **kwargs):
    return Pool().get(model_name).delete(Pool().get(model_name).search(*args, **kwargs))


def pool_search_one(model_name, *args, **kwargs):
    kwargs["limit"] = 1
    return first(Pool().get(model_name).search(*args, **kwargs))


def pool_singleton(model_name):
    return Pool().get(model_name)(1)


def pool_browse(model_name, *args, **kwargs):
    return Pool().get(model_name).browse(*args, **kwargs)


def pool_browse_active_ids(model_name):
    ids = context_active_ids()
    if ids:
        return pool_browse(model_name, ids)
    return None


def is_not_operator(s):
    return s.startswith("!") or s.startswith("not ")


def rec_name_and_or(s_operator):
    return ["AND"] if is_not_operator(s_operator) else ["OR"]


def rec_name_search_fields(fields, clauses):
    return rec_name_and_or(second(clauses)) + list(
        map(lambda field: tuple([field] + list(rest(clauses))), fields)
    )


def create_indexes_code(table_field_code):
    table = table_field_code.table
    return {Index(table, (table_field_code, Index.Similarity()))}


def create_indexes_date(table_field_date):
    return {Index(table_field_date.table, (table_field_date, Index.Range()))}


class NavInFunctionFieldMixin(Model):
    def get_in(self, name):
        path = name.split("__")
        return reduce(
            lambda x, y: None if x is None else getattr(x, y),
            path,
            self,
        )

    def get_in_id(self, name):
        return self.get_in(f"{name}__id")

    @classmethod
    def search_in(cls, name, domain):
        return [(name.replace("__", "."), *tuple(domain[1:]))]

    @staticmethod
    def nav_in_function_field(field):
        return fields.Function(field, "get_in", searcher="search_in")

    @staticmethod
    def nav_in_function_field_m2o(field):
        return fields.Function(field, "get_in_id", searcher="search_in")
