@tool
extends "res://addons/flow_nodes_editor/nodes/attribute_filter_range_settings.gd"

func _init():
	super._init()
	resource_name = "Point Filter Range Settings"
	if attribute_name.strip_edges() == "":
		attribute_name = "position.X"
