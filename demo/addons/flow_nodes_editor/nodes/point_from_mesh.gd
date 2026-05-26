@tool
extends FlowNodeBase

const PointFromMeshNodeSettings = preload("res://addons/flow_nodes_editor/nodes/point_from_mesh_settings.gd")

func _init():
	meta_node = {
		"title" : "Point From Mesh",
		"settings" : PointFromMeshNodeSettings,
		"ins" : [{ "label": "Meshes", "data_type": FlowData.DataType.NodeMesh }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Creates one point per mesh node, using mesh bounds for size and node transform for position/rotation.",
	}

func execute(_ctx : FlowData.EvaluationContext):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input 'Meshes' is not connected")
		return

	var source_stream_name : String = settings.source_stream_name.strip_edges()
	if source_stream_name == "":
		source_stream_name = "node"
	var nodes = in_data.getContainerChecked(source_stream_name, FlowData.DataType.NodeMesh)
	if nodes == null and source_stream_name != "node":
		nodes = in_data.getContainerChecked("node", FlowData.DataType.NodeMesh)
	if nodes == null:
		setError("Input data does not contain a NodeMesh stream (%s)" % source_stream_name)
		return

	var output := FlowData.Data.new()
	output.addCommonStreams(0)
	var spos := output.getVector3Container(FlowData.AttrPosition)
	var srot := output.getVector3Container(FlowData.AttrRotation)
	var ssize := output.getVector3Container(FlowData.AttrSize)

	var out_nodes : Array = []
	var out_meshes : Array[Resource] = []

	for node in nodes:
		var mi := node as MeshInstance3D
		if not mi or mi.mesh == null:
			continue

		var aabb : AABB = mi.mesh.get_aabb()
		var center_local = aabb.position + aabb.size * 0.5
		var trs = mi.global_transform

		var world_size = aabb.size
		if settings.use_world_scale_for_bounds:
			world_size *= trs.basis.get_scale().abs()

		spos.append(trs * center_local)
		srot.append(FlowData.basisToEuler(trs.basis))
		ssize.append(world_size)
		out_nodes.append(mi)
		out_meshes.append(mi.mesh)

	if out_nodes.size() > 0:
		var err = output.registerStream("node", out_nodes, FlowData.DataType.NodeMesh)
		if err:
			setError(err)
			return
		if settings.include_mesh_attribute and settings.mesh_attribute_name != "":
			err = output.registerStream(settings.mesh_attribute_name, out_meshes, FlowData.DataType.Resource)
			if err:
				setError(err)
				return

	set_output(0, output)
