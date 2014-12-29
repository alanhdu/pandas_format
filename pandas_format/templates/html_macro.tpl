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
					{% set d = styler.index_style(rownum, end) %}
					{{ row_header(tuple[0], d) }}
				{% else %}
					{% for i in tuple[0] %}
						{% set d = styler.index_style(rownum, end, loop.index0, outerloop.first) %}
						{% if "rowspan" in d %}
							{{ row_header(i, d) }}
						{% endif %}
					{% endfor %}
				{% endif %}
			{% endif %}
			{% if not split_cols %}
				{% for value in tuple[1:] %}
					{% set d = styler.value_style(rownum, loop.index0) %}
					<td{{ d | inline }}>{{ value | format_value(rownum, loop.index0) }}</td>
				{% endfor %}
			{% else %}
				{% for value in tuple[1:head_col + 1] %}
					{% set d = styler.value_style(rownum, loop.index0) %}
					<td{{ d | inline }}>{{ value | format_value(rownum, loop.index0) }}</td>
				{% endfor %}
				<td> &hellip; </td>
				{% for value in tuple[-tail_col:] %}
					{% set d = styler.value_style(rownum, df.columns | length - loop.revindex) %}
					<td{{ d | inline }}>{{ value | format_value(rownum, df.columns | length - loop.revindex) }} </td>
				{% endfor %}
			{% endif %}
		  </tr>
	{% endfor %}
{% endmacro %}
