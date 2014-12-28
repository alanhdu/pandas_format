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
{% for row in df.itertuples() %}
    {% set outerloop = loop %}
    {% if index %}
        {%- if levels == 1 -%}
            {{ styler.format_index(outerloop.index0) }}
        {%- else -%}
            {% for index in row[0] %} {{ styler.format_index(outerloop.index0, loop.index0) }} {% endfor %}
        {% endif %}
    {% endif %}
    {% if not split_cols %}
        {% for val in row[1:] %} {{ val | format_value(outerloop.index0, loop.index0) }} {% endfor %}
    {% else %}
        {% for val in row[1:head_col + 1] %} {{ val | format_value(outerloop.index0, loop.index0) }} {% endfor %} ... 
        {%- for val in row[-tail_col:] %} {{ val | format_value(outerloop.index0, df.columns | length - loop.revindex) }} {% endfor %}
    {% endif %}

{% endfor %}
{% if show_dimensions %}

[{{ df.shape[0] }} rows x {{ df.shape[1] }} columns]
{%- endif %}
