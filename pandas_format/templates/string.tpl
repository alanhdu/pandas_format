{% if header %}
    {% if index %}
        {% if index_names %}
        {% else %}
        {% endif %}
    {% endif %}
    {% for col in df -%} {{ styler.format_column(loop.index0) }} {% endfor %} 
{% endif %}
{% for row in df.itertuples() %}
    {% set outerloop = loop %}
    {% if index %}
    {% endif %}
    {% for val in row[1:] -%} {{ val | format_value(outerloop.index0, loop.index0) }} {% endfor %}

{% endfor %}
