@tool
extends FlowNodeBase

const AttributeRenameNodeSettings = preload("res://addons/flow_nodes_editor/nodes/attribute_rename_settings.gd")

func _init():
	meta_node = {
		"title" : "Attribute Rename",
		"settings" : AttributeRenameNodeSettings,
		"ins" : [{ "label": "In" }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Renames one attribute/stream while preserving its type and values.",
	}

func execute(_ctx : FlowData.EvaluationContext):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input not found")
		return

	var from_name : String = settings.from_name.strip_edges()
	var to_name : String = settings.to_name.strip_edges()

	if from_name == "" or to_name == "":
		setError("Both source and destination attribute names are required")
		return

	if from_name == to_name:
		set_output(0, in_data.duplicate())
		return

	var out_data : FlowData.Data = in_data.duplicate()
	var stream = out_data.findStream(from_name)
	if stream == null:
		setError("Input does not contain attribute '%s'" % from_name)
		return

	if out_data.hasStream(to_name):
		if not settings.overwrite_existing:
			setError("Destination attribute '%s' already exists" % to_name)
			return
		out_data.delStream(to_name)

	var moved_stream = out_data.streams[from_name]
	out_data.streams.erase(from_name)
	moved_stream.name = to_name
	out_data.streams[to_name] = moved_stream
	if out_data.last_added_stream_name == from_name:
		out_data.last_added_stream_name = to_name

	set_output(0, out_data)
