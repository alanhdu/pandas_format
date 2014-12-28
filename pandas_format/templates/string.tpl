{% if header %}
    {% if index %}
        {% for name in df.index.names -%} {{ styler.format_index_name(loop.index0) }} {%- endfor %}
    {% endif %}
    {% for col in df %} {{ styler.format_column_header(loop.index0) }} {% endfor %} 
{% endif %}
{% for row in df.itertuples() %}
    {% set outerloop = loop %}
    {% if index %}
        {%- if levels == 1 -%}
            {{ styler.format_index(outerloop.index0) }}
        {%- else -%}
            {%- for index in row[0] %} {{ styler.format_index(outerloop.index0, loop.index0) }} {% endfor %}
        {%- endif %}
    {% endif %}
    {% for val in row[1:] %} {{ val | format_value(outerloop.index0, loop.index0) }} {% endfor %}

{% endfor %}
{% if show_dimensions %}

[{{ df.shape[0] }} rows x {{ df.shape[1] }} columns]
{%- endif %}
