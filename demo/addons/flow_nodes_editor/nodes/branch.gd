@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Branch",
		"settings" : BranchNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Out A" }, { "label" : "Out B" }],
		"tooltip" : "Selects one of two outputs based on a Boolean attribute or value.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input is not connected")
		return
	
	var select_a : bool = settings.branch_value
	if settings.use_attribute and settings.attribute_name != "":
		var stream = in_data.findStream(settings.attribute_name)
		if stream == null:
			if ctx.owner == null and Engine.is_editor_hint():
				var empty_data = FlowData.Data.new()
				set_output(0, empty_data)
				set_output(1, empty_data)
				return
			setError("Attribute '%s' not found" % settings.attribute_name)
			return
		if stream.container.size() > 0:
			var val = stream.container[0]
			if val is bool or val is int or val is float:
				select_a = bool(val)
			else:
				select_a = str(val).to_lower() == "true"
	
	var empty_data = FlowData.Data.new()
	if select_a:
		set_output(0, in_data)
		set_output(1, empty_data)
	else:
		set_output(0, empty_data)
		set_output(1, in_data)
