@tool
extends NodeSettings

@export_group("Points From TileMap")
@export var tilemap_path : String = ""
@export var group_name : String = ""
@export var source_id_filter : int = -1
@export var alternative_id_filter : int = -1
@export var height : float = 0.0
@export var cell_size : Vector2 = Vector2(1.0, 1.0)
@export var cell_height : float = 1.0
@export var include_tile_ids : bool = true:
	set(value):
		if include_tile_ids != value:
			include_tile_ids = value
			notify_property_list_changed()
@export var include_layer_ref : bool = false

@export var out_cell_attribute : String = "tile_cell":
	set(value):
		out_cell_attribute = value.strip_edges()
		emit_changed()
@export var out_source_id_attribute : String = "tile_source_id":
	set(value):
		out_source_id_attribute = value.strip_edges()
		emit_changed()
@export var out_alternative_id_attribute : String = "tile_alt_id":
	set(value):
		out_alternative_id_attribute = value.strip_edges()
		emit_changed()
@export var out_layer_attribute : String = "tile_layer":
	set(value):
		out_layer_attribute = value.strip_edges()
		emit_changed()

func _init():
	super._init()
	resource_name = "Points From TileMap Settings"

func exposeParam(name : String) -> bool:
	if name == "out_source_id_attribute" or name == "out_alternative_id_attribute":
		return include_tile_ids
	if name == "out_layer_attribute":
		return include_layer_ref
	return true
