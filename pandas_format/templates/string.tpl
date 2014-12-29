{%- from 'string_macro.tpl' import newline, space, display_rows with context -%}
{%- set split_cols = max_cols < df.columns | length -%}
{%- if header -%}
    {%- if index -%}
        {%- if levels == 1 -%}
            {{- styler.format_index_name() -}}
        {%- else -%}
            {%- for name in df.index.names -%}
                {{- styler.format_index_name(loop.index0) -}} {{- space(loop) -}}
            {%- endfor -%}
        {%- endif -%}
        {{- space() -}}
    {%- endif -%}

    {%- if not split_cols -%}
        {%- for col in df -%} 
            {{- styler.format_column_header(loop.index0) -}}
            {{- space(loop) -}}
        {%- endfor -%} 
    {%- else -%}
        {%- set head_col = (max_cols / 2) | round(0, "ceil") | int -%}
        {%- set tail_col = (max_cols / 2) | round(0, "floor") | int -%}
        {%- for col in df.columns[:head_col] -%} 
            {{- styler.format_column_header(loop.index0) -}}
            {{- space(loop) -}}
        {%- endfor -%}
        {{- space() -}}...{{- space() -}}
        {%- for col in df.columns[-tail_col:] -%} 
            {{- styler.format_column_header(df.columns | length - loop.revindex) -}}
            {{- space(loop) -}}
        {%- endfor -%} 
    {%- endif -%}
    {{- newline() -}}
{%- endif -%}

{%- if max_rows >= (df | length) -%}
    {{- display_rows(df, 0) -}}
{%- else -%}
    {%- set head_rows = (max_rows / 2) | round(0, "floor") | int -%}
    {{- display_rows(df.head(head_rows), 0) -}}
    {{- newline() -}}

    {%- set width = display_rows(df.head(1), 0) | length -%}
    {{- "." * width -}}

    {{- newline() -}}
    {%- set tail_rows = (max_rows / 2) | round(0, "ceil") | int -%}
    {{- display_rows(df.tail(tail_rows), (df | length) - tail_rows) -}}
{%- endif -%}

{%- if show_dimensions -%}
    {{- newline() -}}
    {{- newline() -}}
    [{{ df.shape[0] }} rows x {{ df.shape[1] }} columns]
{%- endif -%}
