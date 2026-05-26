@tool
class_name DungeonWallsAndDoorsSettings
extends NodeSettings

@export_group("Dungeon Walls and Doors")

@export var cell_size : float = 2.0:
	set(value):
		cell_size = value
		emit_changed()

@export var torch_probability : float = 0.15:
	set(value):
		torch_probability = value
		emit_changed()

func _init():
	super._init()
	resource_name = "DungeonWallsAndDoors"
