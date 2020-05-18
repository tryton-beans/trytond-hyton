try:
    from trytond.modules.hyton.tests.test_hyton import suite
except ImportError:
    from .test_hyton import suite

__all__ = ['suite']
