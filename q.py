from __future__ import print_function
from collections import Counter

import numpy as np
import pandas as pd
from pandas.core.common import is_float_dtype
from pandas.core.config import get_option

from jinja2 import Environment, PackageLoader, Template
import jinja2
import markupsafe


import blaze as bz


#df = bz.get_multiindexed_support()
df = pd.read_csv("/home/alan/workspace/vind/test/iris.csv")


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

    def get_rowspan(mi, key, level):
        count = 0
        for ts in mi.index.tolist():
            if ts[level] == key:
                count += 1
        return count

    indices = df.index.tolist()

    env = Environment(loader=PackageLoader("pandas_format"),
                      trim_blocks=True, lstrip_blocks=True)
    env.filters["format_value"] = format_value
    env.globals.update(any=any, get_rowspan=get_rowspan)
    jinja2.filters.FILTERS["format_value"] = format_value
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

print(to_html(df, max_rows=20, max_cols=2, escape=False))
