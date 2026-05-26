@tool
class_name DungeonGeneratorNodeSettings
extends NodeSettings

@export_group("Dungeon Size")
@export var width : int = 20
@export var height : int = 20
@export var cell_size : float = 2.0

@export_group("Rooms Configuration")
@export var max_rooms : int = 8
@export var room_min_size : int = 4
@export var room_max_size : int = 8

@export_group("Decoration")
@export var torch_probability : float = 0.15

func _init():
	super._init()
	resource_name = "Dungeon Generator Settings"
