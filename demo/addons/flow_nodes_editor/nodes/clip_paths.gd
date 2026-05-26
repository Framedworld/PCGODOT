@tool
extends "res://addons/flow_nodes_editor/nodes/clip_points_by_polygon.gd"

const ClipPathsSettings = preload("res://addons/flow_nodes_editor/nodes/clip_points_by_polygon_settings.gd")

func _init():
	meta_node = {
		"title" : "Clip Paths",
		"settings" : ClipPathsSettings,
		"ins" : [{ "label" : "Points" }, { "label" : "Paths" }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "UE naming alias for clipping point sets by Path3D polygons.",
	}
