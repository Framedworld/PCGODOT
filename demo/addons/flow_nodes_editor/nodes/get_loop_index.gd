@tool
extends FlowNodeBase

const GetLoopIndexNodeSettings = preload("res://addons/flow_nodes_editor/nodes/get_loop_index_settings.gd")

func _init():
	meta_node = {
		"title" : "Get Loop Index",
		"settings" : GetLoopIndexNodeSettings,
		"ins" : [{ "label": "In" }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Writes a sequential loop/index attribute for each incoming point.",
	}

func execute(_ctx : FlowData.EvaluationContext):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input not found")
		return

	var out_name = settings.out_name.strip_edges()
	if out_name == "":
		setError("Output name can't be empty")
		return

	var num_points = in_data.size()
	var out_indices := PackedInt32Array()
	out_indices.resize(num_points)
	for i in range(num_points):
		out_indices[i] = settings.start_index + i

	var out_data = in_data.duplicate()
	var err = out_data.registerStream(out_name, out_indices, FlowData.DataType.Int)
	if err:
		setError(err)
		return

	set_output(0, out_data)
