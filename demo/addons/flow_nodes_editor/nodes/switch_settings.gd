@tool
class_name SwitchNodeSettings
extends NodeSettings

@export_group("Switch")

@export var index: int = 0
@export var use_attribute: bool = false
@export var attribute_name: String = ""

func _init():
	super._init()
	resource_name = "Switch Settings"
