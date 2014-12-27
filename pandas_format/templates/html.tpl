{% from 'html_macro.tpl' import column_header, display_rows with context %}
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
						{{ column_header(column)}}
					{% endfor %}
				{% else %}
					{% set head_col = (max_cols / 2) | round(0, "ceil") | int %}
					{% set tail_col = (max_cols / 2) | round(0, "floor") | int %}
					{% for column in df.columns[:head_col] %}
						{{ column_header(column)}}
					{% endfor %}
					{{ column_header("&hellip;") }}
					{% for column in df.columns[-tail_col:] %}
						{{ column_header(column)}}
					{% endfor %}
				{% endif %}
			</tr>
		  </thead>
	  {% endif %}
	  <tbody>
		{% if max_rows >= (df | length) %}
			{{ display_rows(df) }}
		{% else %}
			{% set head_rows = (max_rows / 2) | round(0, "ceil") | int %}
			{{ display_rows(df.head(head_rows)) }}
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
			{{ display_rows(df.tail(tail_rows)) }}
		{% endif %}
	</tbody>
</table>

{% if show_dimensions %}
<p>{{ df.shape[0] }} rows &times; {{ df.shape[1] }} cols</p>
{% endif %}
