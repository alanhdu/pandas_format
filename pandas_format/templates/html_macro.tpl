{% macro row_header(header, d) %}
	{% if bold_rows %}
		<th{{ d | inline }}>{{ header }}</th>
	{% else %}
		<td{{ d | inline }}>{{ header }}</th>
	{% endif %}
{% endmacro %}

{% macro column_header(header, i) %}
	{% set d = styler.header_style(i) %}
	<th{{ d | inline}}> {{ header }} </th>
{% endmacro %}

{% macro display_rows(rows, start) %}
	{% set end = start + rows | length %}
	{% for tuple in rows.itertuples() %}
		{% set rownum = start + loop.index0 %}
		{% set outerloop = loop %}
		<tr{{ styler.row_style(outerloop.index0 + start) | inline }}>
			{% if index %}
				{% if levels == 1 %}
					{% set style = styler.index_style(rownum, end) %}
					{{ row_header(tuple[0], style) }}
				{% else %}
					{% for i in tuple[0] %}
						{% set style = styler.index_style(rownum, end, loop.index0, outerloop.first) %}
						{% if "rowspan" in style %}
							{{ row_header(i, style) }}
						{% endif %}
					{% endfor %}
				{% endif %}
			{% endif %}
			{% if not split_cols %}
				{% for value in tuple[1:] %}
					{% set style = styler.value_style(rownum, loop.index0) %}
					<td{{ style | inline }}>{{ styler.format_value(value, rownum, loop.index0) }}</td>
				{% endfor %}
			{% else %}
				{% for value in tuple[1:head_col + 1] %}
					{% set style = styler.value_style(rownum, loop.index0) %}
					<td{{ style | inline }}>{{ styler.format_value(value, rownum, loop.index0) }}</td>
				{% endfor %}
				<td> &hellip; </td>
				{% for value in tuple[-tail_col:] %}
					{% set colnum = styler.df.columns | length - loop.revindex %}
					{% set style = styler.value_style(rownum, colnum) %}
					<td{{ style | inline }}>{{ styler.format_value(value, rownum, colnum) }}</td>
				{% endfor %}
			{% endif %}
		  </tr>
	{% endfor %}
{% endmacro %}
