@tool
extends FlowNodeBase

const CreateSurfaceFromSplineSettings = preload("res://addons/flow_nodes_editor/nodes/create_surface_from_spline_settings.gd")

func _init():
	meta_node = {
		"title" : "Create Surface From Spline",
		"settings" : CreateSurfaceFromSplineSettings,
		"ins" : [{ "label" : "Splines", "data_type" : FlowData.DataType.NodePath }],
		"outs" : [{ "label" : "Surfaces" }],
		"tooltip" : "Creates one bounds-style surface point from each Path3D polygon/spline.",
	}

func _to_plane(v : Vector3) -> Vector2:
	match settings.plane:
		CreateSurfaceFromSplineSettings.ePlane.XY:
			return Vector2(v.x, v.y)
		CreateSurfaceFromSplineSettings.ePlane.YZ:
			return Vector2(v.y, v.z)
		_:
			return Vector2(v.x, v.z)

func _area(points : PackedVector3Array) -> float:
	if points.size() < 3:
		return 0.0
	var sum := 0.0
	for i in range(points.size()):
		var a := _to_plane(points[i])
		var b := _to_plane(points[(i + 1) % points.size()])
		sum += a.x * b.y - b.x * a.y
	return absf(sum) * 0.5

func _perimeter(points : PackedVector3Array) -> float:
	if points.size() < 2:
		return 0.0
	var sum := 0.0
	for i in range(points.size()):
		sum += points[i].distance_to(points[(i + 1) % points.size()])
	return sum

func _bounds(points : PackedVector3Array) -> AABB:
	var aabb := AABB(points[0], Vector3.ZERO)
	for p in points:
		aabb = aabb.expand(p)
	var min_t := maxf(0.0, settings.minimum_thickness)
	if aabb.size.x < min_t:
		aabb.size.x = min_t
	if aabb.size.y < min_t:
		aabb.size.y = min_t
	if aabb.size.z < min_t:
		aabb.size.z = min_t
	return aabb

func execute(_ctx : FlowData.EvaluationContext):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Splines input not found")
		return
	var stream = in_data.findStream(settings.spline_stream_attribute)
	if stream == null or stream.data_type != FlowData.DataType.NodePath:
		setError("Input must provide a Path3D node stream named '%s'" % settings.spline_stream_attribute)
		return

	var positions := PackedVector3Array()
	var rotations := PackedVector3Array()
	var sizes := PackedVector3Array()
	var areas := PackedFloat32Array()
	var perimeters := PackedFloat32Array()
	var refs : Array = []

	for node in stream.container:
		var path := node as Path3D
		if path == null or path.curve == null:
			continue
		var local_points := path.curve.tessellate(2, 5)
		if local_points.size() < 3:
			local_points = path.curve.get_baked_points()
		if local_points.size() == 0:
			continue
		var world_points := PackedVector3Array()
		for p in local_points:
			world_points.append(path.global_transform * p)
		var aabb := _bounds(world_points)
		positions.append(aabb.position + aabb.size * 0.5)
		rotations.append(Vector3.ZERO)
		sizes.append(aabb.size)
		areas.append(_area(world_points))
		perimeters.append(_perimeter(world_points))
		if settings.include_spline_ref:
			refs.append(path)

	var out := FlowData.Data.new()
	out.addCommonStreams(positions.size())
	var op := out.getVector3Container(FlowData.AttrPosition)
	var orot := out.getVector3Container(FlowData.AttrRotation)
	var osize := out.getVector3Container(FlowData.AttrSize)
	for i in range(positions.size()):
		op[i] = positions[i]
		orot[i] = rotations[i]
		osize[i] = sizes[i]
	if settings.out_area_attribute.strip_edges() != "":
		out.registerStream(settings.out_area_attribute, areas, FlowData.DataType.Float)
	if settings.out_perimeter_attribute.strip_edges() != "":
		out.registerStream(settings.out_perimeter_attribute, perimeters, FlowData.DataType.Float)
	if settings.include_spline_ref and settings.out_spline_attribute.strip_edges() != "":
		out.registerStream(settings.out_spline_attribute, refs, FlowData.DataType.NodePath)
	set_output(0, out)
