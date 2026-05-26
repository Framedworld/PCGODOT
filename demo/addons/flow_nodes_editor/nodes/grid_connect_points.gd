@tool
extends FlowNodeBase

const GridConnectPointsNodeSettings = preload("res://addons/flow_nodes_editor/nodes/grid_connect_points_settings.gd")

func _init():
	meta_node = {
		"title" : "Grid Connect Points",
		"settings" : GridConnectPointsNodeSettings,
		"ins" : [{ "label": "In" }],
		"outs" : [{ "label" : "Cells" }],
		"tooltip" : "Connects ordered points with orthogonal grid-cell paths on the XZ plane.",
	}

func _safe_cell_size() -> Vector3:
	return Vector3(
		maxf(absf(settings.cell_size.x), 0.0001),
		maxf(absf(settings.cell_size.y), 0.0001),
		maxf(absf(settings.cell_size.z), 0.0001)
	)

func _to_cell(pos : Vector3, cell_size : Vector3) -> Vector3i:
	return Vector3i(roundi(pos.x / cell_size.x), roundi(pos.y / cell_size.y), roundi(pos.z / cell_size.z))

func _to_pos(cell : Vector3i, cell_size : Vector3) -> Vector3:
	return Vector3(float(cell.x) * cell_size.x, float(cell.y) * cell_size.y, float(cell.z) * cell_size.z)

func _append_cell(cell : Vector3i, path_idx : int, positions : PackedVector3Array, path_ids : PackedInt32Array, seen : Dictionary, cell_size : Vector3) -> void:
	var key := "%d,%d,%d" % [cell.x, cell.y, cell.z]
	if settings.deduplicate_cells and seen.has(key):
		return
	seen[key] = true
	positions.append(_to_pos(cell, cell_size))
	path_ids.append(path_idx)

func _walk_axis(from_cell : Vector3i, to_cell : Vector3i, axis : String, path_idx : int, positions : PackedVector3Array, path_ids : PackedInt32Array, seen : Dictionary, cell_size : Vector3) -> Vector3i:
	var current := from_cell
	var target_value : int = to_cell.x if axis == "x" else to_cell.z
	while (current.x if axis == "x" else current.z) != target_value:
		if axis == "x":
			current.x += signi(target_value - current.x)
		else:
			current.z += signi(target_value - current.z)
		_append_cell(current, path_idx, positions, path_ids, seen, cell_size)
	return current

func execute(_ctx : FlowData.EvaluationContext):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input not found")
		return
	var in_positions := in_data.getVector3Container(FlowData.AttrPosition)
	if in_positions.size() != in_data.size():
		setError("Input must provide position for each point")
		return

	var cell_size := _safe_cell_size()
	var positions := PackedVector3Array()
	var path_ids := PackedInt32Array()
	var seen := {}
	if in_positions.size() == 1 and settings.include_input_points:
		_append_cell(_to_cell(in_positions[0], cell_size), 0, positions, path_ids, seen, cell_size)

	for idx : int in range(maxi(0, in_positions.size() - 1)):
		var start_cell := _to_cell(in_positions[idx], cell_size)
		var end_cell := _to_cell(in_positions[idx + 1], cell_size)
		if settings.include_input_points:
			_append_cell(start_cell, idx, positions, path_ids, seen, cell_size)
		var current := start_cell
		if settings.axis_order == GridConnectPointsNodeSettings.eAxisOrder.XThenZ:
			current = _walk_axis(current, end_cell, "x", idx, positions, path_ids, seen, cell_size)
			current = _walk_axis(current, end_cell, "z", idx, positions, path_ids, seen, cell_size)
		else:
			current = _walk_axis(current, end_cell, "z", idx, positions, path_ids, seen, cell_size)
			current = _walk_axis(current, end_cell, "x", idx, positions, path_ids, seen, cell_size)
		if settings.include_input_points:
			_append_cell(end_cell, idx, positions, path_ids, seen, cell_size)

	var out_data := FlowData.Data.new()
	out_data.addCommonStreams(positions.size())
	var out_positions := out_data.getVector3Container(FlowData.AttrPosition)
	var out_sizes := out_data.getVector3Container(FlowData.AttrSize)
	for idx : int in range(positions.size()):
		out_positions[idx] = positions[idx]
		out_sizes[idx] = cell_size
	if settings.path_index_attribute != "":
		out_data.registerStream(settings.path_index_attribute, path_ids, FlowData.DataType.Int)
	set_output(0, out_data)
