@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Print String",
		"settings" : PrintStringNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Prints a message that outputs a prefixed message optionally to the log.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input 'In' is not connected")
		return
	
	var prefix = settings.prefix_message
	var attr_name = settings.attribute_to_print
	if attr_name != "":
		var stream = in_data.findStream(attr_name)
		if stream:
			print("%s: Stream '%s' contents: %s" % [prefix, attr_name, str(stream.container)])
		else:
			print("%s: Stream '%s' not found" % [prefix, attr_name])
	else:
		print("%s: Data size = %d" % [prefix, in_data.size()])
		
	set_output(0, in_data)
