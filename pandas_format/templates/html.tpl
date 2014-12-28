{% from 'html_macro.tpl' import column_header, display_rows with context %}
<table{{styler.table_style() | inline}}>
	{% if header %}
		<thead{{styler.thead_style() | inline}}>
			<tr>
				{% if index %}
					{% for name in df.index.names %}
						{% if index_names %}
							<th>{{ name | format_value }}</th>
						{% else %}
							<th></th>
						{% endif %}
					{% endfor %}
				{% endif %}
				{% set split_cols = max_cols < df.columns | length %}
				{% if not split_cols %}
					{% for column in df.columns %}
						{{ column_header(column, loop.index0)}}
					{% endfor %}
				{% else %}
					{% set head_col = (max_cols / 2) | round(0, "ceil") | int %}
					{% set tail_col = (max_cols / 2) | round(0, "floor") | int %}
					{% for column in df.columns[:head_col] %}
						{{ column_header(column, loop.index0)}}
					{% endfor %}
					{{ column_header("&hellip;") }}
					{% for column in df.columns[-tail_col:] %}
						{{ column_header(column, tail_col + loop.index0)}}
					{% endfor %}
				{% endif %}
			</tr>
		  </thead>
	  {% endif %}
	  <tbody{{ styler.tbody_style() | inline }}>
		{% if max_rows >= (df | length) %}
			{{ display_rows(df, 0) }}
		{% else %}
			{% set head_rows = (max_rows / 2) | round(0, "floor") | int %}
			{{ display_rows(df.head(head_rows), 0) }}
			<tr> 
				{% if index %}
					{% for i in range(levels) %}
						<th>&hellip;</th>
					{% endfor %}
				{% endif %}
				{% if split_cols %}
					{% for i in range(max_cols + 1) %}
						<td>&hellip;</td>
					{% endfor %}
				{% else %}
					{% for i in range(df.columns | length) %}
						<td>&hellip;</td>
					{% endfor %}
				{% endif %}
			</tr>
			{% set tail_rows = (max_rows / 2) | round(0, "ceil") | int %}
			{{ display_rows(df.tail(tail_rows), (df | length) - tail_rows) }}
		{% endif %}
	</tbody>
</table>
{% if show_dimensions %}
<p>{{ df.shape[0] }} rows &times; {{ df.shape[1] }} cols</p>
{% endif %}
