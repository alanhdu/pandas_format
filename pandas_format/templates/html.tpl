{% macro row_header(header, rowspan) %}
    {% if col_space is not none %}
        {% set style = "min-width: " ~ col_space ~ ";" %}
    {% else %}
        {% set style = "" %}
    {% endif %}
    {% if rowspan > 1 %}
        {% set row = "rowspan=" ~ rowspan %}
    {% else %}
        {% set row = "" %}
    {% endif %}
    {% if bold_rows %}
        <th {{ style }} {{ row }}>{{ header }}</th>
    {% else %}
        <td {{ style }} {{ row }}>{{ header }}</th>
    {% endif %}
{% endmacro %}

{% macro column_header(header) %}
    {% if col_space is not none %}
        <th style='min-width: {{col_space }};'>{{ header }}</th>
    {% else %}
        <th>{{ header }}</th>
    {% endif %}
{% endmacro %}


{% macro display_rows(rows, start) %}
    {% set dindex = rows.index.tolist() %}
    {% for tuple in rows.itertuples() %}
      {% set outerloop = loop %}
      <tr>
        {% if index %}
           {% if levels == 1 %}
               {{ row_header(tuple[0], 0) }}
           {% else %}
               {% if not sparsify %}
                   {% for i in tuple[0] %}
                       {{ row_header(i, 0) }}
                   {% endfor %}
               {% else %}
                   {% for i in tuple[0] %}
                       {% if outerloop.first or dindex[outerloop.index0 - 1][loop.index0] != i %}
                           {{ row_header(i, get_rowspan(rows, i, loop.index0)) }}
                       {% endif %}
                   {% endfor %}
               {% endif %}
           {% endif %}
        {% endif %}
        {% set row_num = start + loop.index %}
        {% if not split_cols %}
            {% for value in tuple[1:] %}
                {% set col_num = (tuple | length) - loop.revindex - 1 %}
                <td>{{ value | format_value(row_num, col_num) }}</td>
            {% endfor %}
        {% else %}
            {% for value in tuple[1:head_col + 1] %}
                {% set col_num = loop.index %}
                <td>{{ value | format_value(row_num, col_num) }}</td>
            {% endfor %}
            <td> &hellip; </td>
            {% for value in tuple[-tail_col:] %}
                {% set col_num = loop.index %}
                <td>{{ value | format_value(row_num, col_num) }}</td>
            {% endfor %}
        {% endif %}
      </tr>
    {% endfor %}
{% endmacro %}

<table border=1 class="dataframe">
  {% if header %}
      <thead>
        {% if justify is not none %}
            <tr style="text-align: {{ justify }};">
        {% else %}
            <tr>
        {% endif %}
            {% if index %}
                {% for name in df.index.names %}
                    {% if index_names and any(df.index.names) %}
                        <th> {{ name }} </th>
                    {% else %}
                        <th> </th>
                    {% endif %}
                {% endfor %}
            {% endif %}
            {% set split_cols = max_cols < df.columns | length %}
            {% if not split_cols %}
                {% for column in df.columns %}
                    {{ column_header(column) | trim}}
                {% endfor %}
            {% else %}
                {% set head_col = (max_cols / 2) | round(0, "ceil") | int %}
                {% set tail_col = (max_cols / 2) | round(0, "floor") | int %}
                {% for column in df.columns[:head_col] %}
                    {{ column_header(column) | trim}}
                {% endfor %}
                {{ column_header("&hellip;") }}
                {% for column in df.columns[-tail_col:] %}
                    {{ column_header(column) | trim}}
                {% endfor %}
            {% endif %}
        </tr>
      </thead>
  {% endif %}
  <tbody>
    {% if max_rows >= (df | length) %}
        {{ display_rows(df, 0) }}
    {% else %}
        {% set head_rows = (max_rows / 2) | round(0, "ceil") | int %}
        {% set tail_rows = (max_rows / 2) | round(0, "ceil") | int %}
        {{ display_rows(df.head(head_rows), 0) }}
        <tr> 
            {% if index %}
                {% for i in range(levels) %}
                    <th> &hellip; </th>
                {% endfor %}
            {% endif %}

            {% if split_cols %}
                {% for i in range(max_cols + 1) %}
                    <td> &hellip; </td>
                {% endfor %}
            {% else %}
                {% for i in range(df.columns | length) %}
                    <td> &hellip; </td>
                {% endfor %}
            {% endif %}
        </tr>
        {{ display_rows(df.tail(tail_rows), 0) }}
    {% endif %}
  </tbody>
</table>
