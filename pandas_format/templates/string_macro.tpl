{%- set split_cols = max_cols < df.columns | length -%}
{%- if split_cols %}
    {%- set head_col = (max_cols / 2) | round(0, "ceil") | int -%}
    {%- set tail_col = (max_cols / 2) | round(0, "floor") | int -%}
{% endif %}

{%- macro newline(loop=None) -%}
    {%- if loop is none or not loop.last %}

    {% endif -%}
{%- endmacro -%}

{%- macro space(loop=None) -%}
    {%- if loop is none %} {% elif not loop.last %} {% endif -%}
{%- endmacro -%}

{%- macro display_rows(rows, start) -%}
    {%- for row in rows.itertuples() -%}
        {%- set outerloop, rownum = loop, loop.index0 + start -%}
        {%- if index -%}
            {%- if levels == 1 -%}
                {{- styler.format_index(rownum) -}}
            {%- else -%}
                {%- for index in row[0] -%} 
                    {{- styler.format_index(rownum, loop.index0, outerloop.first) -}}
                    {{- space(loop) -}}
                {%- endfor -%}
            {%- endif -%}
            {{- space() -}}
        {%- endif -%}

        {%- if not split_cols -%}
            {%- for val in row[1:] -%}
                {{- styler.format_value(val, rownum, loop.index0) -}}
                {{- space(loop) -}}
            {%- endfor -%}
        {%- else -%}
            {%- for val in row[1:head_col + 1] -%} 
                {{- styler.format_value(val, rownum, loop.index0) -}}
                {{- space(loop) -}}
            {%- endfor -%} 
            
            {{- space() -}}...{{- space() -}}

            {%- for val in row[-tail_col:] -%} 
                {{- styler.format_value(val, rownum, df.columns | length - loop.revindex) -}}
                {{- space(loop) -}}
            {%- endfor -%}
        {%- endif -%}

        {{- newline(loop) -}}
    {%- endfor -%}
{%- endmacro -%}

