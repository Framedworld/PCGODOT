@tool
extends "res://addons/flow_nodes_editor/nodes/points_from_imported_scene.gd"

const LoadAlembicFileSettings = preload("res://addons/flow_nodes_editor/nodes/points_from_imported_scene_settings.gd")

func _init():
	meta_node = {
		"title" : "Load Alembic File",
		"settings" : LoadAlembicFileSettings,
		"ins" : [],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "UE naming alias for loading Alembic/imported scene resources as mesh points.",
	}
