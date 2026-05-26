@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Select (Multi)",
		"settings" : SelectMultiNodeSettings,
		"ins" : [{ "label": "In 0" }, { "label": "In 1" }, { "label": "In 2" }, { "label": "In 3" }], 
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Selects one of multiple inputs to be forwarded to a single output based on an index attribute or value.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var select_idx : int = settings.index
	if settings.use_attribute and settings.attribute_name != "":
		for i in range(4):
			var in_data = get_optional_input(i)
			if in_data:
				var stream = in_data.findStream(settings.attribute_name)
				if stream and stream.container.size() > 0:
					select_idx = int(stream.container[0])
					break
	
	select_idx = clamp(select_idx, 0, 3)
	var selected_data = get_optional_input(select_idx)
	if selected_data == null:
		selected_data = FlowData.Data.new()
	set_output(0, selected_data)
