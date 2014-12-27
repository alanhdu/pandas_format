from __future__ import print_function
from collections import Counter

import numpy as np
import pandas as pd
from pandas.core.common import is_float_dtype
from pandas.core.config import get_option

from jinja2 import Environment, PackageLoader, Template
import markupsafe

def _to_html(df, col_space=None, header=True, index=True, format_value=None,
             inline=None, sparsify=True, index_names=True, justify=True,
             bold_rows=True, classes=None, max_rows=float('inf'), 
             max_cols=float('inf'), show_dimensions=False):

    env = Environment(loader=PackageLoader("pandas_format"),
                      trim_blocks=True, lstrip_blocks=True)
    env.filters["format_value"] = format_value
    def get_rowspan(mi, key, level):
        count = 0
        for ts in mi.index.tolist():
            if ts[level] == key:
                count += 1
        return count
    env.globals.update(get_rowspan=get_rowspan)
    template = env.get_template("html.tpl")

    if isinstance(df.index, pd.MultiIndex):
        levels = len(df.index.levels)
    else:
        levels = 1

    return template.render(df=df, levels=levels, bold_rows=bold_rows,
                header=header, col_space=col_space, index=index, 
                sparsify=sparsify, index_names=index_names,
                justify=justify, max_rows=max_rows, max_cols=max_cols,
                show_dimensions=show_dimensions)

def to_html(df, buf=None, columns=None, col_space=None, header=True,
            index=True, na_rep='NaN', formatters=None,
            float_format=None, sparsify=True, index_names=True,
            justify=None, bold_rows=True, classes=None, escape=True,
            max_rows=float('inf'), max_cols=float('inf'),
            show_dimensions=False):
    if columns is not None:
        df = df[columns]
    if float_format is None:
        float_format = str

    index_names = index_names and any(df.index.names)

    def format_value(value):
        if value != value:
            r = na_rep
        elif is_float_dtype(np.array(value)):
            r = float_format(value)
        else:
            r = str(value)

        if escape:
            return markupsafe.escape(r)
        else:
            return r

    def inline(row, col):
        d = {}
        if col_space is not None and row < 0 or col < 0:
            d[style] = "minwidth: {};".format(col_space)

        return {}

    return _to_html(df, col_space, header, index, format_value, inline, sparsify,
                    index_names, justify, bold_rows, classes, max_rows,
                    max_cols, show_dimensions)
