@tool
extends NodeSettings

@export_group("Points From GridMap")
@export var gridmap_path : String = ""
@export var group_name : String = ""
@export var item_id_filter : int = -1
@export var y_offset : float = 0.0
@export var include_item_id : bool = true:
	set(value):
		if include_item_id != value:
			include_item_id = value
			notify_property_list_changed()
@export var include_gridmap_ref : bool = false

@export var out_cell_attribute : String = "grid_cell":
	set(value):
		out_cell_attribute = value.strip_edges()
		emit_changed()
@export var out_item_id_attribute : String = "grid_item_id":
	set(value):
		out_item_id_attribute = value.strip_edges()
		emit_changed()
@export var out_gridmap_attribute : String = "gridmap_node":
	set(value):
		out_gridmap_attribute = value.strip_edges()
		emit_changed()

func _init():
	super._init()
	resource_name = "Points From GridMap Settings"

func exposeParam(name : String) -> bool:
	if name == "out_item_id_attribute":
		return include_item_id
	if name == "out_gridmap_attribute":
		return include_gridmap_ref
	return true
