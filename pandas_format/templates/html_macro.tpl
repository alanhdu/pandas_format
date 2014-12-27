{% macro row_header(header, rowspan) %}
    {% if col_space is not none %}
        {% set style = " style = 'min-width: " ~ col_space ~ ";'" %}
    {% else %}
        {% set style = "" %}
    {% endif %}
    {% if rowspan > 1 %}
        {% set row = " rowspan=" ~ rowspan %}
    {% else %}
        {% set row = "" %}
    {% endif %}
    {% if bold_rows %}
        <th{{ style }}{{ row }}>{{ header | format_value }}</th>
    {% else %}
        <td{{ style }}{{ row }}>{{ header | format_value }}</th>
    {% endif %}
{% endmacro %}

{% macro column_header(header) %}
    {% if col_space is not none %}
        <th style='min-width: {{col_space }};'>{{ header | format_value}}</th>
    {% else %}
        <th>{{ header }}</th>
    {% endif %}
{% endmacro %}

{% macro display_rows(rows) %}
    {% set dindex = rows.index.tolist() %}
    {% for tuple in rows.itertuples() %}
        {% set outerloop = loop %}
        <tr>
            {% if index %}
                {% if levels == 1 %}
                    {{ row_header(tuple[0], 0) }}
                {% else %}
                    {% for i in tuple[0] %}
                        {% if not sparsify %}
                            {{ row_header(i, 0) }}
                        {% elif outerloop.first or dindex[outerloop.index0 - 1][loop.index0] != i %}
                            {{ row_header(i, get_rowspan(rows, i, loop.index0)) }}
                        {% endif %}
                    {% endfor %}
               {% endif %}
            {% endif %}
            {% if not split_cols %}
                {% for value in tuple[1:] %}
                    <td>{{ value | format_value }}</td>
                {% endfor %}
            {% else %}
                {% for value in tuple[1:head_col + 1] %}
                    <td>{{ value | format_value }}</td>
                {% endfor %}
                <td> &hellip; </td>
                {% for value in tuple[-tail_col:] %}
                    <td>{{ value | format_value }}</td>
                {% endfor %}
            {% endif %}
          </tr>
    {% endfor %}
{% endmacro %}
