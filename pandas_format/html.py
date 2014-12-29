import numpy as np
import pandas as pd

import markupsafe

from .core import Styler, env

def _inline(key, value):
    if value is None:
        return str(key)
    else:
        return str(key) + "=" + repr(value)
def dict_to_inline(d):
    if d:
        return " " + " ".join(_inline(k, v) for k, v in d.items())
    else:
        return ""

def _to_html(df, header=True, index=True, index_names=True,
             bold_rows=True, max_rows=float('inf'), max_cols=float('inf'),
             show_dimensions=False, styler=None):
    env.filters["inline"] = dict_to_inline

    template = env.get_template("html.tpl")

    if isinstance(df.index, pd.MultiIndex):
        levels = len(df.index.levels)
    else:
        levels = 1

    return template.render(df=df, styler=styler, levels=levels, header=header,
                           bold_rows=bold_rows, index_names=index_names,
                           index=index, max_rows=max_rows, max_cols=max_cols,
                           showdimensions=show_dimensions)

def to_html(df, buf=None, columns=None, col_space=None, header=True,
            index=True, na_rep='NaN', formatters=None, float_format=str,
            sparsify=True, index_names=True, justify=None, bold_rows=True,
            classes=None, escape=True, max_rows=float('inf'),
            max_cols=float('inf'), show_dimensions=False):
    if columns is not None:
        df = df[columns]

    index_names = index_names and any(df.index.names)
    styler = DefaultHtmlStyler(df, col_space, na_rep, formatters, float_format,
                        justify, sparsify, classes, escape)

    ret = _to_html(df, header, index, index_names, bold_rows, max_rows,
                   max_cols, show_dimensions, styler)
    if buf is None:
        return ret
    else:
        buf.write(ret)

class HtmlStyler(Styler):
    def table_style(self):
        return {"border": 1, "class": "dataframe"}

    def tbody_style(self):
        return {}

    def thead_style(self):
        return {}

class DefaultHtmlStyler(HtmlStyler):
    def __init__(self, df, col_space=None, na_rep='NaN', formatters=None,
                 float_format=str, justify=None, sparsify=True, classes=None,
                 escape=True):
        super(DefaultHtmlStyler, self).__init__(df, na_rep, formatters,
                                                float_format)

        self.col_space = col_space
        self.escape = escape
        self.justify = justify

        self.sparsify = sparsify

        self.classes = classes

    def format_value(self, value, row, col):
        value = super(DefaultHtmlStyler, self).format_value(value, row, col)

        if self.escape:
            return markupsafe.escape(value)
        else:
            return value

    def index_style(self, rownum, end, level=None, first=False):
        inline = {}
        if self.col_space is not None:
            inline["style"] = "min-width: {};".format(self.col_space)

        if level is not None and self.sparsify:
            current = self.indices[rownum][level]
            if first or self.indices[rownum-1][level] != current:
                inline["rowspan"] = 1
                for index in self.indices[rownum+1:end]:
                    if index[level] == current:
                        inline["rowspan"] += 1
                    else:
                        break
        return inline

    def header_style(self, i):
        if self.col_space is not None:
            return {"style": "min-width: {};".format(self.col_space)}
        else:
            return {}

    def table_style(self):
        inline = super(DefaultHtmlStyler, self).table_style()
        if isinstance(self.classes, str):
            inline["class"] += " " + self.classes
        elif self.classes is not None:
            inline["class"] += " " + " ".join(self.classes)
        return inline

    def thead_style(self):
        if self.justify is not None:
            return {"style": "text-align: {};".format(self.justify)}
        else:
            return {}
