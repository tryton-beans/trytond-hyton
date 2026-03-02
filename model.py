from trytond.pool import Pool

from .sugar import save
from .utils import first


def create_model(model_name, *args, **kwargs):
    return Pool().get(model_name)(*args, **kwargs)


def create_save_model(model_name, *args, **kwargs):
    return save(create_model(model_name, *args, **kwargs))


def reload_model(model):
    return Pool().get(model.__name__)(model.id)


def load_first_model(model_name, domain):
    return first(Pool().get(model_name).search(domain, limit=1))
