from __future__ import print_function

import numpy as np
import pandas as pd
from pandas.core.common import is_float_dtype

from jinja2 import Environment, PackageLoader

from .core import Styler

def _to_string(df, header=True, index=True, max_rows=float('inf'), 
               max_cols=float('inf'),
               show_dimensions=False, styler=None):
    env = Environment(loader=PackageLoader("pandas_format"), trim_blocks=True,
                      lstrip_blocks=True)
    env.filters["format_value"] = styler.format_value
    env.globals["styler"] = styler

    template = env.get_template("string.tpl")

    if isinstance(df.index, pd.MultiIndex):
        levels = len(df.index.levels)
    else:
        levels = 1

    return template.render(df=df, header=header, index=index, levels=levels,
                           show_dimensions=show_dimensions, max_rows=max_rows,
                           max_cols=max_cols)

def to_string(df, buf=None, columns=None, col_space=0, header=True,
              index=True, na_rep='NaN', formatters=None, float_format=str,
              sparsify=True, index_names=True, justify="left", line_width=True,
              max_rows=float('inf'), max_cols=float('inf'), show_dimensions=False):
    if columns is not None:
        df = df[columns]
    index_names = index_names and any(df.index.names)

    styler = StringStyler(df, col_space, na_rep, formatters, float_format,
                          justify, sparsify, index_names)

    ret = _to_string(df, header, index, max_rows, max_cols,
                     show_dimensions, styler)
    if buf is None:
        return ret
    else:
        buf.write(ret)

def pad(string, width, justify="left"):
    l = width - len(string)
    if justify == "left":
        return string + l * " "
    elif justify == "right":
        return l * " " + string
    elif justify == "center":
        p = " " * (l // 2)
        if l % 2 == 0:
            return p + string + p
        else:
            return " " + p + string + p
    else:
        raise Exception()


class StringStyler(Styler):
    def __init__(self, df, col_space=0, na_rep='NaN', formatters=None,
                 float_format=str, justify="left", sparsify=True, index_names=True):
        super(StringStyler, self).__init__(df, na_rep, formatters, float_format)

        self.col_space = col_space
        self.justify = justify
        self.sparsify = sparsify
        self.index_names = index_names

        self.widths = [col_space for x in df.columns]
        for r, row in enumerate(df.itertuples()):
            for c, value in enumerate(row[1:]):
                value = self.format_value(value, r, c)
                self.widths[c] = max(self.widths[c], len(value))
        for i, column in enumerate(df):
            self.widths[i] = max(self.widths[i], len(str(column)))

        if isinstance(self.indices[0], tuple):
            self.index_widths = [max(len(str(x)) for x in xs)
                                 for xs in zip(*self.indices)]
        else:
            self.index_widths = [max(len(str(x)) for x in self.indices)]

        if self.index_names:
            for i, name in enumerate(self.df.index.names):
                self.index_widths[i] = max(self.index_widths[i], len(str(name)))

    def format_value(self, value, row, col):
        value = super(StringStyler, self).format_value(value, row, col)

        if len(value) < self.widths[col]:
            return pad(value, self.widths[col], self.justify)
        else:
            return value

    def format_column_header(self, col):
        column = str(self.df.columns[col])
        return pad(column, self.widths[col], self.justify)

    def format_index(self, row, level=0, first=None):
        value = self.indices[row]
        if isinstance(value, tuple):
            value = value[level]

        if not self.sparsify or first or self.indices[row - 1][level] != value:
            return pad(str(value), self.index_widths[level])
        else:
            return " " * self.index_widths[level]
        
    def format_index_name(self, level=0):
        if self.index_names:
            name = str(self.df.index.names[level])
            return pad(name, self.index_widths[level], self.justify)
        else:
            return " " * self.index_widths[level]
