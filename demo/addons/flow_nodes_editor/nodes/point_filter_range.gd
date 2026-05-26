@tool
extends "res://addons/flow_nodes_editor/nodes/attribute_filter_range.gd"

const PointFilterRangeNodeSettings = preload("res://addons/flow_nodes_editor/nodes/point_filter_range_settings.gd")

func _init():
	meta_node = {
		"title" : "Point Filter Range",
		"settings" : PointFilterRangeNodeSettings,
		"ins" : [{ "label": "In" }],
		"outs" : [{ "label" : "Inside" }, { "label" : "Outside" }],
		"tooltip" : "Point-focused alias of Attribute Filter Range (defaults to position.X).",
	}
