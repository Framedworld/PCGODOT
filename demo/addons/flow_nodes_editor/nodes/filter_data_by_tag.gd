@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Filter Data By Tag",
		"settings" : FilterDataByTagNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Inside" }, { "label" : "Outside" }],
		"tooltip" : "Separates data according to their tags. You can specify a comma-separated list of Tags to filter by.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input 'In' is not connected")
		return
	
	var filter_tags := []
	var raw_tags = settings.tags.split(",")
	for raw in raw_tags:
		var clean = raw.strip_edges()
		if clean != "":
			filter_tags.append(clean)
			
	var match_found = false
	for tag in in_data.tags:
		if tag in filter_tags:
			match_found = true
			break
			
	var empty_data = FlowData.Data.new()
	if match_found:
		set_output(0, in_data)
		set_output(1, empty_data)
	else:
		set_output(0, empty_data)
		set_output(1, in_data)
