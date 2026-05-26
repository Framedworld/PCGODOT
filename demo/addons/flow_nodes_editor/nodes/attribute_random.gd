@tool
extends FlowNodeBase

const AttributeRandomNodeSettings = preload("res://addons/flow_nodes_editor/nodes/attribute_random_settings.gd")

func _init():
	meta_node = {
		"title" : "Attribute Random",
		"settings" : AttributeRandomNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Sets an attribute on points to random values or sequential indices.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		if ctx.owner == null and Engine.is_editor_hint():
			set_output(0, FlowData.Data.new())
			return
		setError("Input 'In' is not connected")
		return
		
	var out_data : FlowData.Data = in_data.duplicate()
	var size = in_data.size()
	
	var seed_val = getSettingValue(ctx, "random_seed", 12345)
	var rng = RandomNumberGenerator.new()
	
	if settings.data_type == AttributeRandomNodeSettings.eType.Int:
		var container := PackedInt32Array()
		container.resize(size)
		for i in range(size):
			if settings.use_index_as_value:
				container[i] = i
			else:
				# Deterministic seed per point based on global seed + point index
				rng.seed = seed_val + i * 256
				container[i] = rng.randi_range(int(settings.min_value), int(settings.max_value))
		out_data.registerStream(settings.attribute_name, container, FlowData.DataType.Int)
	else:
		var container := PackedFloat32Array()
		container.resize(size)
		for i in range(size):
			if settings.use_index_as_value:
				container[i] = float(i)
			else:
				rng.seed = seed_val + i * 256
				container[i] = rng.randf_range(settings.min_value, settings.max_value)
		out_data.registerStream(settings.attribute_name, container, FlowData.DataType.Float)
		
	set_output(0, out_data)
