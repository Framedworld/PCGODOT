@tool
extends "res://addons/flow_nodes_editor/nodes/copy.gd"

func _init():
	meta_node = {
		"title" : "Copy Points",
		"settings" : CopyNodeSettings,
		"ins" : [{ "label": "Source" }, { "label": "Targets" }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Godot-facing alias of Copy for point data.",
	}
