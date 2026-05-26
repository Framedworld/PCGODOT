@tool
extends "res://addons/flow_nodes_editor/nodes/size.gd"

const SizeNodeSettings = preload("res://addons/flow_nodes_editor/nodes/size_settings.gd")

func _init():
	meta_node = {
		"title" : "Get Points Count",
		"settings" : SizeNodeSettings,
		"ins" : [{ "label" : "In" }],
		"outs" : [{ "label" : "Count", "data_type" : FlowData.DataType.Int }],
		"tooltip" : "UE naming alias of Size. Outputs total points as a single integer stream.",
	}
