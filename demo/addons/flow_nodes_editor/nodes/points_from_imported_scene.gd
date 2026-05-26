@tool
extends FlowNodeBase

const PointsFromImportedSceneSettings = preload("res://addons/flow_nodes_editor/nodes/points_from_imported_scene_settings.gd")

func _init():
	meta_node = {
		"title" : "Points From Imported Scene",
		"settings" : PointsFromImportedSceneSettings,
		"ins" : [],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Loads imported scene/mesh resources and emits one point per mesh instance or mesh asset.",
	}

func _append_mesh_point(mi : MeshInstance3D, positions : PackedVector3Array, rotations : PackedVector3Array, sizes : PackedVector3Array, meshes : Array, names : PackedStringArray, paths : PackedStringArray, source_path : String) -> void:
	if mi == null or mi.mesh == null:
		return
	var tr := mi.global_transform
	var aabb := mi.mesh.get_aabb()
	var center := tr * (aabb.position + aabb.size * 0.5)
	var size : Vector3 = settings.fallback_size
	if settings.use_mesh_bounds:
		size = aabb.size * tr.basis.get_scale().abs()
	positions.append(center)
	rotations.append(FlowData.basisToEuler(tr.basis))
	sizes.append(size)
	if settings.include_mesh_resource:
		meshes.append(mi.mesh)
	if settings.include_source_name:
		names.append(mi.name)
	if settings.include_source_path:
		paths.append(source_path)

func _walk_meshes(node : Node, positions : PackedVector3Array, rotations : PackedVector3Array, sizes : PackedVector3Array, meshes : Array, names : PackedStringArray, paths : PackedStringArray, source_path : String) -> void:
	var mi := node as MeshInstance3D
	if mi:
		_append_mesh_point(mi, positions, rotations, sizes, meshes, names, paths, source_path)
	for child in node.get_children():
		_walk_meshes(child, positions, rotations, sizes, meshes, names, paths, source_path)

func execute(_ctx : FlowData.EvaluationContext):
	var path : String = settings.asset_path.strip_edges()
	if path == "":
		set_output(0, FlowData.Data.new())
		return
	if not ResourceLoader.exists(path):
		setError("Imported scene/mesh asset '%s' was not found" % path)
		return
	var res = load(path)
	if res == null:
		setError("Failed to load imported asset '%s'" % path)
		return

	var positions := PackedVector3Array()
	var rotations := PackedVector3Array()
	var sizes := PackedVector3Array()
	var meshes : Array[Resource] = []
	var names := PackedStringArray()
	var paths := PackedStringArray()

	if res is PackedScene:
		var root = res.instantiate()
		if root:
			_walk_meshes(root, positions, rotations, sizes, meshes, names, paths, path)
			root.queue_free()
	elif res is Mesh:
		var aabb : AABB = res.get_aabb()
		positions.append(aabb.position + aabb.size * 0.5)
		rotations.append(Vector3.ZERO)
		sizes.append(aabb.size if settings.use_mesh_bounds else settings.fallback_size)
		if settings.include_mesh_resource:
			meshes.append(res)
		if settings.include_source_name:
			names.append(path.get_file())
		if settings.include_source_path:
			paths.append(path)
	else:
		setError("Asset '%s' is not a PackedScene or Mesh resource" % path)
		return

	var out := FlowData.Data.new()
	out.addCommonStreams(positions.size())
	var op := out.getVector3Container(FlowData.AttrPosition)
	var orot := out.getVector3Container(FlowData.AttrRotation)
	var osize := out.getVector3Container(FlowData.AttrSize)
	for i in range(positions.size()):
		op[i] = positions[i]
		orot[i] = rotations[i]
		osize[i] = sizes[i]
	if settings.include_mesh_resource and settings.mesh_attribute.strip_edges() != "":
		out.registerStream(settings.mesh_attribute, meshes, FlowData.DataType.Resource)
	if settings.include_source_name and settings.source_name_attribute.strip_edges() != "":
		out.registerStream(settings.source_name_attribute, names, FlowData.DataType.String)
	if settings.include_source_path and settings.source_path_attribute.strip_edges() != "":
		out.registerStream(settings.source_path_attribute, paths, FlowData.DataType.String)
	set_output(0, out)
