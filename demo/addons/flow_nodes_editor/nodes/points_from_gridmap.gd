@tool
extends FlowNodeBase

const PointsFromGridMapSettings = preload("res://addons/flow_nodes_editor/nodes/points_from_gridmap_settings.gd")

func _init():
	meta_node = {
		"title" : "Points From GridMap",
		"settings" : PointsFromGridMapSettings,
		"scans_scene" : true,
		"ins" : [],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Generates one point per used GridMap cell (Godot-specific 3D tile extraction).",
	}

func _collect_gridmaps(root : Node) -> Array:
	if root == null:
		return []
	var path = settings.gridmap_path.strip_edges()
	if path != "":
		var single = root.get_node_or_null(path)
		if single and single.is_class("GridMap"):
			return [single]
		setError("GridMap path '%s' was not found or is not a GridMap" % path)
		return []

	var group_name = settings.group_name.strip_edges()
	if group_name != "":
		var out : Array = []
		for n in root.get_tree().get_nodes_in_group(group_name):
			if n and n.is_class("GridMap"):
				out.append(n)
		return out

	return root.find_children("*", "GridMap", true, false)

func execute(_ctx : FlowData.EvaluationContext):
	var root = EditorInterface.get_edited_scene_root()
	if root == null:
		set_output(0, FlowData.Data.new())
		return

	var grids = _collect_gridmaps(root)
	if grids.is_empty():
		set_output(0, FlowData.Data.new())
		return

	var positions := PackedVector3Array()
	var rotations := PackedVector3Array()
	var sizes := PackedVector3Array()
	var cells := PackedVector3Array()
	var item_ids := PackedInt32Array()
	var grid_refs : Array = []

	for grid in grids:
		var used_cells = grid.get_used_cells()
		var csize : Vector3 = grid.cell_size
		for cell in used_cells:
			var item_id = grid.get_cell_item(cell)
			if settings.item_id_filter >= 0 and item_id != settings.item_id_filter:
				continue
			var local_pos : Vector3 = grid.map_to_local(cell)
			var world_pos : Vector3 = grid.to_global(local_pos)
			world_pos.y += settings.y_offset

			positions.append(world_pos)
			rotations.append(Vector3.ZERO)
			sizes.append(csize)
			cells.append(Vector3(cell.x, cell.y, cell.z))
			if settings.include_item_id:
				item_ids.append(item_id)
			if settings.include_gridmap_ref:
				grid_refs.append(grid)

	var out := FlowData.Data.new()
	out.addCommonStreams(positions.size())
	var op = out.getVector3Container(FlowData.AttrPosition)
	var orot = out.getVector3Container(FlowData.AttrRotation)
	var osize = out.getVector3Container(FlowData.AttrSize)
	for i in range(positions.size()):
		op[i] = positions[i]
		orot[i] = rotations[i]
		osize[i] = sizes[i]

	if settings.out_cell_attribute.strip_edges() != "":
		out.registerStream(settings.out_cell_attribute, cells, FlowData.DataType.Vector)
	if settings.include_item_id and settings.out_item_id_attribute.strip_edges() != "":
		out.registerStream(settings.out_item_id_attribute, item_ids, FlowData.DataType.Int)
	if settings.include_gridmap_ref and settings.out_gridmap_attribute.strip_edges() != "":
		out.registerStream(settings.out_gridmap_attribute, grid_refs, FlowData.DataType.NodePath)

	set_output(0, out)
