@tool
extends "res://addons/flow_nodes_editor/nodes/scan_nodes.gd"

const PointsFromSceneNodeSettings = preload("res://addons/flow_nodes_editor/nodes/points_from_scene_settings.gd")

func _init():
	meta_node = {
		"title" : "Points From Scene",
		"settings" : PointsFromSceneNodeSettings,
		"scans_scene" : true,
		"ins" : [],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Generates one point per scene node and optionally imports metadata and selected properties.",
	}
