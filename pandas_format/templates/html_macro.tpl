{%- macro newline() %}

{% endmacro -%}

{%- macro tab(level=1) -%}
    {%- for l in range(level) %}  {% endfor -%}
{%- endmacro -%}

{%- macro row_header(header, d) -%}
    {{- tab(3) -}}
    {%- if bold_rows -%}
        <th {{- d | inline -}}> {{- header -}} </th>
    {%- else -%}
        <td {{- d | inline -}}> {{- header -}} </th>
    {%- endif -%}
    {{- newline() -}}
{%- endmacro -%}

{%- macro column_header(header, i) -%}
    {%- set d = styler.header_style(i) -%}
    {{ tab(3) }} <th {{- d | inline-}}> {{- header -}} </th> {{- newline() -}}
{%- endmacro -%}

{%- macro display_rows(rows, start) -%}
    {%- set end = start + rows | length -%}
    {%- for tuple in rows.itertuples() -%}
        {%- set rownum = start + loop.index0 -%}
        {%- set outerloop = loop -%}
        {{- tab(2) -}} <tr {{- styler.row_style(outerloop.index0 + start) | inline -}}> {{- newline() -}}
            {%- if index -%}
                {%- if levels == 1 -%}
                    {%- set style = styler.index_style(rownum, end) -%}
                    {{- row_header(tuple[0], style) -}}
                {%- else -%}
                    {%- for i in tuple[0] -%}
                        {%- set style = styler.index_style(rownum, end, loop.index0, outerloop.first) -%}
                        {%- if "rowspan" in style -%}
                            {{- row_header(i, style) -}}
                        {%- endif -%}
                    {%- endfor -%}
                {%- endif -%}
            {%- endif -%}
            {%- if not split_cols -%}
                {%- for value in tuple[1:] -%}
                    {%- set style = styler.value_style(rownum, loop.index0) -%}
                    {{- tab(3) -}}
                    <td{{- style | inline -}}>{{- styler.format_value(value, rownum, loop.index0) -}}</td>
                    {{- newline() -}}
                {%- endfor -%}
            {%- else -%}
                {%- for value in tuple[1:head_col + 1] -%}
                    {%- set style = styler.value_style(rownum, loop.index0) -%}
                    {{- tab(3) -}}
                    <td{{- style | inline -}}>{{- styler.format_value(value, rownum, loop.index0) -}}</td>
                    {{- newline() -}}
                {%- endfor -%}
                <td> &hellip; </td> {{- newline() -}}
                {%- for value in tuple[-tail_col:] -%}
                    {%- set colnum = styler.df.columns | length - loop.revindex -%}
                    {%- set style = styler.value_style(rownum, colnum) -%}
                    {{- tab(3) -}}
                    <td{{- style | inline -}}>{{- styler.format_value(value, rownum, colnum) -}}</td>
                    {{- newline() -}}
                {%- endfor -%}
            {%- endif -%}
        {{- tab(2) -}} </tr> {{- newline() -}}
    {%- endfor -%}
{%- endmacro -%}
