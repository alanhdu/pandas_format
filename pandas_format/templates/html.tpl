{%- from 'html_macro.tpl' import column_header, display_rows, newline, tab with context -%}
<table{{- styler.table_style() | inline -}}> {{- newline() -}}
    {%- if header -%}
        {{- tab() -}} <thead {{- styler.thead_style() | inline -}}> {{- newline() -}}
            {{- tab(2) -}} <tr> {{- newline() -}}
                {%- if index -%}
                    {%- for name in styler.df.index.names -%}
                        {{- tab(3) -}}
                        {%- if index_names -%}
                            <th>{{- name -}}</th>
                        {%- else -%}
                            <th></th>
                        {%- endif -%}
                        {{- newline() -}}
                    {%- endfor -%}
                {%- endif -%}
                {%- set split_cols = max_cols < styler.df.columns | length -%}
                {%- if not split_cols -%}
                    {%- for column in styler.df.columns -%}
                        {{- column_header(column, loop.index0)-}}
                    {%- endfor -%}
                {%- else -%}
                    {%- set head_col = (max_cols / 2) | round(0, "ceil") | int -%}
                    {%- set tail_col = (max_cols / 2) | round(0, "floor") | int -%}
                    {%- for column in styler.df.columns[:head_col] -%}
                        {{- column_header(column, loop.index0)-}}
                    {%- endfor -%}
                    {{- column_header("&hellip;") -}}
                    {%- for column in styler.df.columns[-tail_col:] -%}
                        {{- column_header(column, (styler.df.columns | length) - loop.revindex)-}}
                    {%- endfor -%}
                {%- endif -%}
            {{- tab(2) -}} </tr> {{- newline() -}}
            {{- tab(1) -}} </thead> {{- newline() -}}
        {%- endif -%}
    {{- tab(1) -}} <tbody {{- styler.tbody_style() | inline -}}> {{- newline() -}}
        {%- if max_rows >= (styler.df | length) -%}
            {{- display_rows(styler.df, 0) -}}
        {%- else -%}
            {%- set head_rows = (max_rows / 2) | round(0, "floor") | int -%}
            {{- display_rows(styler.df.head(head_rows), 0) -}}
            {{- tab(2) -}} <tr> {{- newline() -}}
                {%- if index -%}
                    {%- for i in range(levels) -%}
                        {{- tab(3) -}} <th>&hellip;</th> {{- newline() -}}
                    {%- endfor -%}
                {%- endif -%}
                {%- if split_cols -%}
                    {%- for i in range(max_cols + 1) -%}
                        {{- tab(3) -}} <td>&hellip;</td> {{- newline() -}}
                    {%- endfor -%}
                {%- else -%}
                    {%- for i in range(styler.df.columns | length) -%}
                        {{- tab(3) -}} <td>&hellip;</td> {{- newline() -}}
                    {%- endfor -%}
                {%- endif -%}
            {{- tab(3) -}} </tr>
            {%- set tail_rows = (max_rows / 2) | round(0, "ceil") | int -%}
            {{- display_rows(styler.df.tail(tail_rows), (styler.df | length) - tail_rows) -}}
        {%- endif -%}
    {{- tab(1) -}} </tbody> {{- newline() -}}
</table> {{- newline() -}}
{%- if show_dimensions -%}
<p>{{- styler.df.shape[0] }} rows &times; {{ styler.df.shape[1] }} columns</p>
{%- endif -%}
