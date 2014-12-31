{%- from 'string_macro.tpl' import newline, space, display_rows with context -%}
{%- set split_cols = max_cols < styler.df.columns | length -%}
{%- if header -%}
    {%- if index -%}
        {%- if levels == 1 -%}
            {{- styler.format_index_name() -}}
        {%- else -%}
            {%- for name in styler.df.index.names -%}
                {{- styler.format_index_name(loop.index0) -}} {{- space(loop) -}}
            {%- endfor -%}
        {%- endif -%}
        {{- space() -}}
    {%- endif -%}

    {%- if not split_cols -%}
        {%- for col in styler.df.columns -%} 
            {{- styler.format_column_header(loop.index0) -}}
            {{- space(loop) -}}
        {%- endfor -%} 
    {%- else -%}
        {%- set head_col = (max_cols / 2) | round(0, "ceil") | int -%}
        {%- set tail_col = (max_cols / 2) | round(0, "floor") | int -%}
        {%- for col in styler.df.columns[:head_col] -%} 
            {{- styler.format_column_header(loop.index0) -}}
            {{- space(loop) -}}
        {%- endfor -%}
        {{- space() -}}...{{- space() -}}
        {%- for col in styler.df.columns[-tail_col:] -%} 
            {{- styler.format_column_header(styler.df.columns | length - loop.revindex) -}}
            {{- space(loop) -}}
        {%- endfor -%} 
    {%- endif -%}
    {{- newline() -}}
{%- endif -%}

{%- if max_rows >= (styler.df | length) -%}
    {{- display_rows(styler.df, 0) -}}
{%- else -%}
    {%- set head_rows = (max_rows / 2) | round(0, "floor") | int -%}
    {{- display_rows(styler.df.head(head_rows), 0) -}}
    {{- newline() -}}

    {%- set width = display_rows(styler.df.head(1), 0) | length -%}
    {{- "." * width -}}

    {{- newline() -}}
    {%- set tail_rows = (max_rows / 2) | round(0, "ceil") | int -%}
    {{- display_rows(styler.df.tail(tail_rows), (styler.df | length) - tail_rows) -}}
{%- endif -%}

{%- if show_dimensions -%}
    {{- newline() -}}
    {{- newline() -}}
    [{{ styler.df.shape[0] }} rows x {{ styler.df.shape[1] }} columns]
{%- endif -%}
