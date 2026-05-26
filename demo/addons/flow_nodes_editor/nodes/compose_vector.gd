@tool
extends FlowNodeBase

const ComposeVectorNodeSettings = preload("res://addons/flow_nodes_editor/nodes/compose_vector_settings.gd")

func _init():
	meta_node = {
		"title" : "Compose Vector",
		"settings" : ComposeVectorNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Composes a Vector3 attribute from float attributes or default values.",
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
	
	var sx = in_data.findStream(settings.x_attribute) if settings.x_attribute != "" else null
	var sy = in_data.findStream(settings.y_attribute) if settings.y_attribute != "" else null
	var sz = in_data.findStream(settings.z_attribute) if settings.z_attribute != "" else null
	
	var out_vec := PackedVector3Array()
	out_vec.resize(size)
	
	for i in range(size):
		var vx = sx.container[i] if sx else settings.default_value.x
		var vy = sy.container[i] if sy else settings.default_value.y
		var vz = sz.container[i] if sz else settings.default_value.z
		out_vec[i] = Vector3(vx, vy, vz)
		
	var err = out_data.registerStream(settings.out_attribute, out_vec, FlowData.DataType.Vector)
	if err:
		setError(err)
		return
		
	set_output(0, out_data)
