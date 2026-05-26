@tool
class_name SelectMultiNodeSettings
extends NodeSettings

@export_group("Select Multi")

@export var index: int = 0
@export var use_attribute: bool = false
@export var attribute_name: String = ""

func _init():
	super._init()
	resource_name = "Select Multi Settings"
