@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Build Rotation From Up Vector",
		"settings" : BuildRotationFromUpNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Computes rotation from an up vector stream or constant and applies it to the points.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input 'In' is not connected")
		return
	
	var out_data : FlowData.Data = in_data.duplicate()
	var srot : PackedVector3Array = out_data.cloneStream(FlowData.AttrRotation)
	var num_elems = in_data.size()
	
	var use_constant = settings.use_constant
	var up_const = settings.up_vector_constant
	var attr_name = settings.up_vector_attribute
	var axis_val = settings.axis
	
	var stream_up = null
	if not use_constant and attr_name != "":
		stream_up = in_data.findStream(attr_name)
		if stream_up == null:
			if ctx.owner == null and Engine.is_editor_hint():
				var empty_data = FlowData.Data.new()
				set_output(0, empty_data)
				return
			setError("Up vector attribute '%s' not found" % attr_name)
			return
			
	for i in num_elems:
		var up_vec = up_const
		if stream_up:
			up_vec = stream_up.container[i]
		var basis = FlowData.basisFromNormal(up_vec, Vector3.UP if abs(up_vec.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT, axis_val)
		srot[i] = FlowData.basisToEuler(basis)
		
	out_data.registerStream(FlowData.AttrRotation, srot, FlowData.DataType.Vector)
	set_output(0, out_data)
