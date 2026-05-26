@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Filter Data By Attribute",
		"settings" : FilterDataByAttributeNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Inside" }, { "label" : "Outside" }],
		"tooltip" : "Separates data based on whether they have a specified metadata attribute.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input 'In' is not connected")
		return
		
	var attr_name = settings.attribute_name
	var match_found = false
	if attr_name != "":
		match_found = in_data.hasStream(attr_name)
		
	var empty_data = FlowData.Data.new()
	if match_found:
		set_output(0, in_data)
		set_output(1, empty_data)
	else:
		set_output(0, empty_data)
		set_output(1, in_data)
