{% from 'html_macro.tpl' import column_header, display_rows with context %}
<table{{styler.table_style() | inline}}>
	{% if header %}
		<thead{{styler.thead_style() | inline}}>
			<tr>
				{% if index %}
					{% for name in styler.df.index.names %}
						{% if index_names %}
							<th>{{ name }}</th>
						{% else %}
							<th></th>
						{% endif %}
					{% endfor %}
				{% endif %}
				{% set split_cols = max_cols < styler.df.columns | length %}
				{% if not split_cols %}
					{% for column in styler.df.columns %}
						{{ column_header(column, loop.index0)}}
					{% endfor %}
				{% else %}
					{% set head_col = (max_cols / 2) | round(0, "ceil") | int %}
					{% set tail_col = (max_cols / 2) | round(0, "floor") | int %}
					{% for column in styler.df.columns[:head_col] %}
						{{ column_header(column, loop.index0)}}
					{% endfor %}
					{{ column_header("&hellip;") }}
					{% for column in styler.df.columns[-tail_col:] %}
						{{ column_header(column, (styler.df.columns | length) - loop.revindex)}}
					{% endfor %}
				{% endif %}
			</tr>
		  </thead>
	  {% endif %}
	  <tbody{{ styler.tbody_style() | inline }}>
		{% if max_rows >= (styler.df | length) %}
			{{ display_rows(styler.df, 0) }}
		{% else %}
			{% set head_rows = (max_rows / 2) | round(0, "floor") | int %}
			{{ display_rows(styler.df.head(head_rows), 0) }}
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
					{% for i in range(styler.df.columns | length) %}
						<td>&hellip;</td>
					{% endfor %}
				{% endif %}
			</tr>
			{% set tail_rows = (max_rows / 2) | round(0, "ceil") | int %}
			{{ display_rows(styler.df.tail(tail_rows), (styler.df | length) - tail_rows) }}
		{% endif %}
	</tbody>
</table>
{% if show_dimensions %}
<p>{{ styler.df.shape[0] }} rows &times; {{ styler.df.shape[1] }} cols</p>
{% endif %}
