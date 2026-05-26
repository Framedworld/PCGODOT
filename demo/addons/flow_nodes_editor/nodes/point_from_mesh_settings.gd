@tool
extends "res://addons/flow_nodes_editor/node_settings.gd"

@export_group("Point From Mesh")
@export var source_stream_name : String = "node":
	set(value):
		source_stream_name = value.strip_edges()
		emit_changed()
@export var include_mesh_attribute : bool = true:
	set(value):
		if include_mesh_attribute != value:
			include_mesh_attribute = value
			notify_property_list_changed()
@export var mesh_attribute_name : String = "mesh":
	set(value):
		mesh_attribute_name = value.strip_edges()
		emit_changed()
@export var use_world_scale_for_bounds : bool = true:
	set(value):
		use_world_scale_for_bounds = value
		emit_changed()

func _init():
	super._init()
	resource_name = "Point From Mesh Settings"

func exposeParam(name : String) -> bool:
	if name == "mesh_attribute_name":
		return include_mesh_attribute
	return true
