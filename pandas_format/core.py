from collections import Mapping, Sequence

from jinja2 import Environment, PackageLoader
from pandas.core.common import is_float_dtype
import numpy as np

env = Environment(loader=PackageLoader("pandas_format"), trim_blocks=True,
                  lstrip_blocks=True)

class Styler(object):
    def __init__(self, df, na_rep="NaN", formatters=None, float_format=str):
        self.df = df
        self.indices = df.index.tolist()

        self.formatters = formatters
        self.na_rep = na_rep
        self.float_format = float_format

        if isinstance(self.formatters, Sequence):
            if len(self.formatters) != len(self.df.columns):
                raise IndexError

    def format_value(self, value, row, col):
        if self.formatters is not None:
            if isinstance(self.formatters, Mapping):
                column = self.df.columns[col]
                if column in self.formatters:
                    return self.formatters[column](value)
            elif isinstance(self.formatters, Sequence):
                if len(self.df.columns) == len(self.formatters):
                    return self.formatters[col](value)
                else:
                    raise IndexError
            else:
                raise Exception

        if value != value:
            value = self.na_rep
        elif is_float_dtype(np.array(value)):
            value = self.float_format(value)
        else:
            value = str(value)

        return value

    def index_style(self, i, level=None, first=False):
        return {}

    def header_style(self, i):
        return {}

    def value_style(self, row, col):
        return {}

    def row_style(self, i):
        return {}
