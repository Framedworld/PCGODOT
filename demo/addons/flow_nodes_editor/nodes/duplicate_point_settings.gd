@tool
class_name DuplicatePointNodeSettings
extends NodeSettings

@export_group("Duplicate Point")

@export var iterations: int = 1
@export var offset: Vector3 = Vector3(0, 1, 0)
@export var offset_relative: bool = true

func _init():
	super._init()
	resource_name = "Duplicate Point Settings"
