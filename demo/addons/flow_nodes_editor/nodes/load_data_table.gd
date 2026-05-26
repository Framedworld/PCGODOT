@tool
extends FlowNodeBase

const LoadDataTableSettings = preload("res://addons/flow_nodes_editor/nodes/load_data_table_settings.gd")

func _init():
	meta_node = {
		"title" : "Load Data Table",
		"settings" : LoadDataTableSettings,
		"ins" : [],
		"outs" : [{ "label" : "Rows" }],
		"tooltip" : "Loads CSV/TSV-style rows as attribute-set data with typed columns.",
	}

func _delimiter() -> String:
	match settings.delimiter:
		LoadDataTableSettings.eDelimiter.Tab:
			return "\t"
		LoadDataTableSettings.eDelimiter.Semicolon:
			return ";"
		LoadDataTableSettings.eDelimiter.Pipe:
			return "|"
		_:
			return ","

func _parse_delimited_text(text : String, delimiter : String) -> Array:
	var rows : Array = []
	var row : Array[String] = []
	var cell := ""
	var in_quotes := false
	var i := 0
	while i < text.length():
		var ch := text.substr(i, 1)
		if ch == "\"":
			if in_quotes and i + 1 < text.length() and text.substr(i + 1, 1) == "\"":
				cell += "\""
				i += 1
			else:
				in_quotes = not in_quotes
		elif ch == delimiter and not in_quotes:
			row.append(cell)
			cell = ""
		elif (ch == "\n" or ch == "\r") and not in_quotes:
			if ch == "\r" and i + 1 < text.length() and text.substr(i + 1, 1) == "\n":
				i += 1
			row.append(cell)
			rows.append(row)
			row = []
			cell = ""
		else:
			cell += ch
		i += 1
	row.append(cell)
	rows.append(row)

	while not rows.is_empty():
		var last : Array = rows[rows.size() - 1]
		if last.size() == 1 and String(last[0]).strip_edges() == "":
			rows.pop_back()
		else:
			break
	return rows

func _clean_value(value : String) -> String:
	return value.strip_edges() if settings.trim_values else value

func _make_unique_headers(headers : Array[String]) -> Array[String]:
	var used := {}
	var out : Array[String] = []
	for i in range(headers.size()):
		var base := _clean_value(headers[i]).replace(" ", "_")
		if base == "":
			base = "column_%d" % i
		var candidate := base
		var suffix := 1
		while used.has(candidate):
			candidate = "%s_%d" % [base, suffix]
			suffix += 1
		used[candidate] = true
		out.append(candidate)
	return out

func _try_parse_vector(value : String) -> Dictionary:
	var v := _clean_value(value)
	if v == "":
		return { "ok": true, "value": Vector3.ZERO }
	if v.begins_with("(") and v.ends_with(")"):
		v = v.substr(1, v.length() - 2)
	v = v.replace(",", " ").replace(";", " ").replace("|", " ")
	var parts := v.split(" ", false)
	if parts.size() != 3:
		return { "ok": false, "value": Vector3.ZERO }
	for part in parts:
		if not String(part).is_valid_float():
			return { "ok": false, "value": Vector3.ZERO }
	return { "ok": true, "value": Vector3(float(parts[0]), float(parts[1]), float(parts[2])) }

func _infer_type(values : Array[String]) -> int:
	if not settings.infer_column_types:
		return FlowData.DataType.String
	var can_bool := true
	var can_int := true
	var can_float := true
	var can_vector := true
	for raw in values:
		var v := _clean_value(raw)
		if v == "":
			continue
		var lower := v.to_lower()
		if lower != "true" and lower != "false":
			can_bool = false
		if not v.is_valid_int():
			can_int = false
		if not v.is_valid_float():
			can_float = false
		if not _try_parse_vector(v).ok:
			can_vector = false
	if can_bool:
		return FlowData.DataType.Bool
	if can_int:
		return FlowData.DataType.Int
	if can_float:
		return FlowData.DataType.Float
	if can_vector:
		return FlowData.DataType.Vector
	return FlowData.DataType.String

func _register_column(out : FlowData.Data, name : String, values : Array[String]) -> void:
	var data_type := _infer_type(values)
	match data_type:
		FlowData.DataType.Bool:
			var c := PackedByteArray()
			c.resize(values.size())
			for i in range(values.size()):
				c[i] = 1 if _clean_value(values[i]).to_lower() == "true" else 0
			out.registerStream(name, c, FlowData.DataType.Bool)
		FlowData.DataType.Int:
			var c := PackedInt32Array()
			c.resize(values.size())
			for i in range(values.size()):
				var v := _clean_value(values[i])
				c[i] = int(v) if v != "" else 0
			out.registerStream(name, c, FlowData.DataType.Int)
		FlowData.DataType.Float:
			var c := PackedFloat32Array()
			c.resize(values.size())
			for i in range(values.size()):
				var v := _clean_value(values[i])
				c[i] = float(v) if v != "" else 0.0
			out.registerStream(name, c, FlowData.DataType.Float)
		FlowData.DataType.Vector:
			var c := PackedVector3Array()
			c.resize(values.size())
			for i in range(values.size()):
				c[i] = _try_parse_vector(values[i]).value
			out.registerStream(name, c, FlowData.DataType.Vector)
		_:
			var c := PackedStringArray()
			c.resize(values.size())
			for i in range(values.size()):
				c[i] = _clean_value(values[i])
			out.registerStream(name, c, FlowData.DataType.String)

func execute(_ctx : FlowData.EvaluationContext):
	var path : String = settings.table_path.strip_edges()
	if path == "":
		set_output(0, FlowData.Data.new())
		return
	if not FileAccess.file_exists(path):
		setError("Data table path '%s' was not found" % path)
		return
	var text := FileAccess.get_file_as_string(path)
	var rows := _parse_delimited_text(text, _delimiter())
	if rows.is_empty():
		set_output(0, FlowData.Data.new())
		return

	var headers : Array[String] = []
	var start_row := 0
	if settings.first_row_is_header:
		for h in rows[0]:
			headers.append(String(h))
		start_row = 1
	else:
		var width := 0
		for row in rows:
			width = maxi(width, row.size())
		for i in range(width):
			headers.append("column_%d" % i)
	headers = _make_unique_headers(headers)

	var row_count = max(0, rows.size() - start_row)
	var columns : Array = []
	columns.resize(headers.size())
	for i in range(headers.size()):
		var col : Array[String] = []
		col.resize(row_count)
		columns[i] = col

	for r in range(row_count):
		var row : Array = rows[start_row + r]
		for c in range(headers.size()):
			columns[c][r] = String(row[c]) if c < row.size() else ""

	var out := FlowData.Data.new()
	for c in range(headers.size()):
		_register_column(out, headers[c], columns[c])

	if settings.add_row_index and settings.row_index_attribute.strip_edges() != "":
		var idxs := PackedInt32Array()
		idxs.resize(row_count)
		for i in range(row_count):
			idxs[i] = i
		out.registerStream(settings.row_index_attribute, idxs, FlowData.DataType.Int)
	if settings.add_source_path and settings.source_path_attribute.strip_edges() != "":
		var paths := PackedStringArray()
		paths.resize(row_count)
		for i in range(row_count):
			paths[i] = path
		out.registerStream(settings.source_path_attribute, paths, FlowData.DataType.String)

	set_output(0, out)
