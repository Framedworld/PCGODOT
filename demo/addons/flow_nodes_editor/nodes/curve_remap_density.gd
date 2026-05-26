@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Curve Remap Density",
		"settings" : CurveRemapDensityNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Remaps the density of each point in the point data to another density value according to the provided curve.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input 'In' is not connected")
		return
	
	var out_data : FlowData.Data = in_data.duplicate()
	var s_density = in_data.findStream("density")
	
	var num_elems = in_data.size()
	var densities := PackedFloat32Array()
	densities.resize(num_elems)
	
	var in_container = s_density.container if s_density else null
	var c : Curve = settings.remap_curve
	if c == null:
		# If no curve is specified, use a default linear curve behavior
		c = Curve.new()
		
	for i in num_elems:
		var d = in_container[i] if in_container else 1.0
		densities[i] = c.sample(d)
		
	out_data.registerStream("density", densities, FlowData.DataType.Float)
	set_output(0, out_data)
