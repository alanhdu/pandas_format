import pandas as pd

from .core import Styler, env

def _to_string(styler, header=True, index=True, max_rows=float('inf'),
               max_cols=float('inf'), show_dimensions=False):
    template = env.get_template("string.tpl")

    if isinstance(styler.df.index, pd.MultiIndex):
        levels = len(styler.df.index.levels)
    else:
        levels = 1

    return template.render(styler=styler, header=header, index=index,
                           levels=levels, max_rows=max_rows, max_cols=max_cols,
                           show_dimensions=show_dimensions)

def to_string(df, buf=None, columns=None, col_space=0, header=True, index=True,
              na_rep='NaN', formatters=None, float_format=str, sparsify=True,
              index_names=True, justify="left", line_width=True,
              max_rows=float('inf'), max_cols=float('inf'),
              show_dimensions=False):
    if columns is not None:
        df = df[columns]
    index_names = index_names and any(df.index.names)

    styler = StringStyler(df, col_space, na_rep, formatters, float_format,
                          justify, sparsify, index_names)

    ret = _to_string(styler, header, index, max_rows, max_cols,
                     show_dimensions)
    if buf is None:
        return ret
    else:
        buf.write(ret)


class StringStyler(Styler):
    def __init__(self, df, col_space=0, na_rep='NaN', formatters=None,
                 float_format=str, justify="left", sparsify=True, 
                 index_names=True):
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

    def pad(self, string, width):
        width = width - len(string)
        if self.justify == "left":
            return string + width * " "
        elif self.justify == "right":
            return width * " " + string
        elif self.justify == "center":
            half = " " * (width // 2)
            if width % 2 == 0:
                return half + string + half
            else:
                return " " + half + string + half
        else:
            raise Exception()

    def format_value(self, value, row, col):
        value = super(StringStyler, self).format_value(value, row, col)

        if len(value) < self.widths[col]:
            return self.pad(value, self.widths[col])
        else:
            return value

    def format_column_header(self, col):
        column = str(self.df.columns[col])
        return self.pad(column, self.widths[col])

    def format_index(self, row, level=0, first=None):
        value = self.indices[row]
        if isinstance(value, tuple):
            value = value[level]

            if not self.sparsify or first or self.indices[row - 1][level] != value:
                return self.pad(str(value), self.index_widths[level])
            else:
                return " " * self.index_widths[level]
        else:
            return self.pad(str(value), self.index_widths[level])

    def format_index_name(self, level=0):
        if self.index_names:
            name = str(self.df.index.names[level])
            return self.pad(name, self.index_widths[level])
        else:
            return " " * self.index_widths[level]
