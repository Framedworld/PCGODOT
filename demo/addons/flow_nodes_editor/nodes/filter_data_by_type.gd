@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Filter Data By Type",
		"settings" : FilterDataByTypeNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Inside" }, { "label" : "Outside" }],
		"tooltip" : "Separates data based on their type, as dictated by the Target Type.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input 'In' is not connected")
		return
		
	var target = settings.target_type
	var match_found = false
	
	var has_points = in_data.hasStream(FlowData.AttrPosition) and in_data.hasStream(FlowData.AttrRotation) and in_data.hasStream(FlowData.AttrSize)
	var has_splines = in_data.hasStream("node") and in_data.streams["node"].data_type == FlowData.DataType.NodePath
	
	if target == FilterDataByTypeNodeSettings.eTargetType.PointData:
		match_found = has_points
	elif target == FilterDataByTypeNodeSettings.eTargetType.SplineData:
		match_found = has_splines
	elif target == FilterDataByTypeNodeSettings.eTargetType.AttributeSet:
		match_found = not has_points and not has_splines and in_data.streams.size() > 0
		
	var empty_data = FlowData.Data.new()
	if match_found:
		set_output(0, in_data)
		set_output(1, empty_data)
	else:
		set_output(0, empty_data)
		set_output(1, in_data)
