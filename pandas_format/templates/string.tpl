{% macro display_rows(rows, start) %}
    {% for row in rows.itertuples() %}
        {% set outerloop = loop %}
        {% if index %}
            {%- if levels == 1 -%}
                {{ styler.format_index(outerloop.index0 + start) }}
            {%- else -%}
                {% for index in row[0] %} {{ styler.format_index(outerloop.index0 + start, loop.index0, outerloop.first) }} {% endfor %}
            {% endif %}
        {% endif %}
        {% if not split_cols %}
            {% for val in row[1:] %} {{ val | format_value(outerloop.index0 + start, loop.index0) }} {% endfor %}
        {% else %}
            {% for val in row[1:head_col + 1] %} {{ val | format_value(outerloop.index0 + start, loop.index0) }} {% endfor %} ... 
            {%- for val in row[-tail_col:] %} {{ val | format_value(outerloop.index0 + start, df.columns | length - loop.revindex) }} {% endfor %}
        {% endif %}

    {% endfor %}
{% endmacro %}

{% set split_cols = max_cols < df.columns | length %}
{% if header %}
    {% if index %}
        {% if levels == 1 -%} {{ styler.format_index_name() }} {%- else %}
            {% for name in df.index.names %} {{ styler.format_index_name(loop.index0) }} {% endfor %}
        {% endif %}
    {% endif %}
    {% if not split_cols %}
        {% for col in df %} {{ styler.format_column_header(loop.index0) }} {% endfor %} 
    {% else %}
        {% set head_col = (max_cols / 2) | round(0, "ceil") | int %}
        {% set tail_col = (max_cols / 2) | round(0, "floor") | int %}
        {% for col in df.columns[:head_col] %} {{ styler.format_column_header(loop.index0) }} {% endfor %} ... 
        {%- for col in df.columns[-tail_col:] %} {{ styler.format_column_header(df.columns | length - loop.revindex) }} {% endfor %} 
    {% endif %}
{% endif %}
{% if max_rows >= (df | length) -%}
    {{ display_rows(df, 0) }}
{%- else %}
    {% set head_rows = (max_rows / 2) | round(0, "floor") | int -%}
    {{ display_rows(df.head(head_rows), 0) }}
    {%- set width = display_rows(df.head(1), 0) | length -%}
    {{ "." * width }}
    {% set tail_rows = (max_rows / 2) | round(0, "ceil") | int -%}
    {{ display_rows(df.tail(tail_rows), (df | length) - tail_rows) }}
{% endif %}
{% if show_dimensions %}

[{{ df.shape[0] }} rows x {{ df.shape[1] }} columns]
{%- endif %}
