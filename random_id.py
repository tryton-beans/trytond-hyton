import random
from functools import reduce
from operator import add

from cytoolz import take
from hyrule import assoc
from trytond.model import Index
from trytond.pool import Pool

from .utils import is_empty, is_none


def repeatedly(func):
    while True:
        yield func()


def dec(n):
    return n - 1


def create_random_str(letters, size):
    length = len(letters)
    return reduce(
        add,
        take(size, repeatedly(lambda: letters[dec(random.randint(1, length))])),
    )


def create_indexes_identifier(table_field):
    table = table_field.table
    return {Index(table, (table_field, Index.Similarity()))}


def create_id(size=8, prefix=""):
    return prefix + create_random_str("23456879ABCDEFGHJKLMNPQRSTUVWXYZ", size)


def get_new_id(model, field, size=8, prefix=""):
    the_model = Pool().get(model)
    new_identifier = create_id(size, prefix)
    while not is_empty(the_model.search([(field, "=", new_identifier)])):
        new_identifier = create_id(size, prefix)
    return new_identifier


def add_identifier(values, model_name, size=8, prefix="", known_ids=None):
    if known_ids is None:
        known_ids = set()
    identifier = values.get("identifier", None)
    if is_none(identifier) or identifier == "":
        generated_id = get_new_id(model_name, "identifier", size, prefix)
        while generated_id in known_ids:
            generated_id = get_new_id(model_name, "identifier", size, prefix)
        known_ids.add(generated_id)
        assoc(values, "identifier", generated_id)
