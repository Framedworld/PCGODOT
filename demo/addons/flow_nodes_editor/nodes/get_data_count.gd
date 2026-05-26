@tool
extends "res://addons/flow_nodes_editor/nodes/size.gd"

func _init():
	meta_node = {
		"title" : "Get Data Count",
		"settings" : SizeNodeSettings,
		"ins" : [{ "label" : "In"}],
		"outs" : [{ "label" : "Count", "data_type" : FlowData.DataType.Int }],
		"tooltip" : "Returns the number of entries in the input data.",
	}
