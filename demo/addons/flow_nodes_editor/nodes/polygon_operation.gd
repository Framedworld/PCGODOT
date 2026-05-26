@tool
extends "res://addons/flow_nodes_editor/nodes/clip_points_by_polygon.gd"

const PolygonOperationSettings = preload("res://addons/flow_nodes_editor/nodes/clip_points_by_polygon_settings.gd")

func _init():
	meta_node = {
		"title" : "Polygon Operation",
		"settings" : PolygonOperationSettings,
		"ins" : [{ "label" : "Points" }, { "label" : "Polygon" }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "UE naming alias for polygon clipping/filter operations.",
	}
