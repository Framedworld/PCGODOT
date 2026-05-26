@tool
class_name SanityCheckNodeSettings
extends NodeSettings

@export_group("Sanity Check")

@export var attribute_name: String = "density"
@export var min_value: float = 0.0
@export var max_value: float = 1.0

func _init():
	super._init()
	resource_name = "Sanity Check Settings"
