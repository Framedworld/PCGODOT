@tool
extends FlowNodeBase

const GridFillBoundsNodeSettings = preload("res://addons/flow_nodes_editor/nodes/grid_fill_bounds_settings.gd")

func _init():
	meta_node = {
		"title" : "Grid Fill Bounds",
		"settings" : GridFillBoundsNodeSettings,
		"ins" : [{ "label": "Bounds" }],
		"outs" : [{ "label" : "Cells" }],
		"tooltip" : "Creates one point per grid cell inside input bounds, or inside configured bounds when no input is connected.",
	}

func _safe_cell_size() -> Vector3:
	return Vector3(
		maxf(absf(settings.cell_size.x), 0.0001),
		maxf(absf(settings.cell_size.y), 0.0001),
		maxf(absf(settings.cell_size.z), 0.0001)
	)

func _append_bounds(center : Vector3, size : Vector3, cell_size : Vector3, out_positions : PackedVector3Array, seen : Dictionary) -> PackedVector3Array:
	var half_size := size.abs() * 0.5
	var min_pos := center - half_size
	var max_pos := center + half_size
	var min_x : int = floori(min_pos.x / cell_size.x)
	var max_x : int = ceili(max_pos.x / cell_size.x) - 1
	var min_y : int = floori(min_pos.y / cell_size.y)
	var max_y : int = ceili(max_pos.y / cell_size.y) - 1
	var min_z : int = floori(min_pos.z / cell_size.z)
	var max_z : int = ceili(max_pos.z / cell_size.z) - 1
	if not settings.fill_y_axis:
		min_y = roundi(center.y / cell_size.y)
		max_y = min_y

	for x : int in range(min_x, max_x + 1):
		for y : int in range(min_y, max_y + 1):
			for z : int in range(min_z, max_z + 1):
				var key := "%d,%d,%d" % [x, y, z]
				if seen.has(key):
					continue
				seen[key] = true
				var out_y : float = center.y if not settings.fill_y_axis else (float(y) + 0.5) * cell_size.y
				out_positions.append(Vector3(
					(float(x) + 0.5) * cell_size.x,
					out_y,
					(float(z) + 0.5) * cell_size.z
				))
				if out_positions.size() >= settings.max_points:
					return out_positions
	return out_positions

func execute(_ctx : FlowData.EvaluationContext):
	var cell_size := _safe_cell_size()
	var positions := PackedVector3Array()
	var seen := {}
	var in_data : FlowData.Data = get_optional_input(0)

	if settings.use_input_bounds and in_data != null and in_data.size() > 0:
		var in_positions := in_data.getVector3Container(FlowData.AttrPosition)
		var in_sizes := in_data.getVector3Container(FlowData.AttrSize)
		if in_positions.size() != in_data.size():
			setError("Input bounds must provide position for each point")
			return
		for idx : int in range(in_data.size()):
			var size : Vector3 = settings.bounds_size
			if in_sizes.size() == in_data.size():
				size = in_sizes[idx]
			elif in_sizes.size() == 1:
				size = in_sizes[0]
			positions = _append_bounds(in_positions[idx], size, cell_size, positions, seen)
			if positions.size() >= settings.max_points:
				break
	else:
		positions = _append_bounds(settings.bounds_center, settings.bounds_size, cell_size, positions, seen)

	var out_data := FlowData.Data.new()
	out_data.addCommonStreams(positions.size())
	var out_positions := out_data.getVector3Container(FlowData.AttrPosition)
	var out_sizes := out_data.getVector3Container(FlowData.AttrSize)
	for idx : int in range(positions.size()):
		out_positions[idx] = positions[idx]
		out_sizes[idx] = cell_size
	set_output(0, out_data)
