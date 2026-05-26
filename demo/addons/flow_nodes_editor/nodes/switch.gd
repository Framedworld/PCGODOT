@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Switch",
		"settings" : SwitchNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Out 0" }, { "label" : "Out 1" }, { "label" : "Out 2" }, { "label" : "Out 3" }],
		"tooltip" : "Routes the input to one of multiple outputs based on an index attribute or value.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input is not connected")
		return
	
	var select_idx : int = settings.index
	if settings.use_attribute and settings.attribute_name != "":
		var stream = in_data.findStream(settings.attribute_name)
		if stream and stream.container.size() > 0:
			select_idx = int(stream.container[0])
	
	select_idx = clamp(select_idx, 0, 3)
	var empty_data = FlowData.Data.new()
	for i in range(4):
		if i == select_idx:
			set_output(i, in_data)
		else:
			set_output(i, empty_data)
