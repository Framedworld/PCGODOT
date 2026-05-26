@tool
extends FlowNodeBase

const MutateSeedNodeSettings = preload("res://addons/flow_nodes_editor/nodes/mutate_seed_settings.gd")

func _init():
	meta_node = {
		"title" : "Mutate Seed",
		"settings" : MutateSeedNodeSettings,
		"ins" : [{ "label": "In" }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Generates deterministic per-point seed values from existing seeds, index, and optional position.",
	}

func _seed_from_stream(stream, idx : int) -> int:
	if stream == null:
		return idx
	var size = stream.container.size()
	if size <= 0:
		return idx
	var read_idx = idx if size > 1 else 0
	match stream.data_type:
		FlowData.DataType.Int:
			return int(stream.container[read_idx])
		FlowData.DataType.Float:
			return int(round(stream.container[read_idx]))
		FlowData.DataType.Bool:
			return 1 if stream.container[read_idx] != 0 else 0
	return idx

func _mutate_seed(base_seed : int, idx : int, pos : Vector3) -> int:
	var h = hash([base_seed, idx, settings.random_seed, settings.seed_offset])
	if settings.include_position:
		var px = int(round(pos.x * 1000.0))
		var py = int(round(pos.y * 1000.0))
		var pz = int(round(pos.z * 1000.0))
		h = hash([h, px, py, pz])
	var mutated = h & 0x7fffffff

	match settings.mode:
		MutateSeedNodeSettings.eMode.Add:
			return int(base_seed + mutated + settings.seed_offset)
		MutateSeedNodeSettings.eMode.Xor:
			return int(base_seed ^ mutated)
		_:
			return int(mutated)

func execute(_ctx : FlowData.EvaluationContext):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input not found")
		return

	var out_name = settings.out_seed_attribute.strip_edges()
	if out_name == "":
		setError("Output seed attribute name can't be empty")
		return

	var num_points = in_data.size()
	if num_points == 0:
		set_output(0, in_data.duplicate())
		return

	var in_seed_name = settings.in_seed_attribute.strip_edges()
	var in_seed_stream = null
	if in_seed_name != "":
		in_seed_stream = in_data.findStream(in_seed_name)
		if in_seed_stream and in_seed_stream.data_type != FlowData.DataType.Int and in_seed_stream.data_type != FlowData.DataType.Float and in_seed_stream.data_type != FlowData.DataType.Bool:
			setError("Input seed attribute '%s' must be Int/Float/Bool" % in_seed_name)
			return
		if in_seed_stream:
			var seed_size = in_seed_stream.container.size()
			if seed_size != num_points and seed_size != 1:
				setError("Input seed attribute '%s' must have %d values or 1 value (got %d)" % [in_seed_name, num_points, seed_size])
				return

	var positions := PackedVector3Array()
	if settings.include_position:
		positions = in_data.getVector3Container(FlowData.AttrPosition)
		if positions.size() != num_points:
			setError("Input must provide %s with %d values when include_position is enabled" % [FlowData.AttrPosition, num_points])
			return

	var out_seeds := PackedInt32Array()
	out_seeds.resize(num_points)
	for i in range(num_points):
		var base_seed = _seed_from_stream(in_seed_stream, i)
		var pos = positions[i] if settings.include_position else Vector3.ZERO
		out_seeds[i] = _mutate_seed(base_seed, i, pos)

	var out_data = in_data.duplicate()
	var err = out_data.registerStream(out_name, out_seeds, FlowData.DataType.Int)
	if err:
		setError(err)
		return
	set_output(0, out_data)
