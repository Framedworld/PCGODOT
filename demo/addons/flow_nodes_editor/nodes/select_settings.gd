@tool
class_name SelectNodeSettings
extends NodeSettings

@export_group("Select")

@export var select_b: bool = false
@export var use_attribute: bool = false
@export var attribute_name: String = ""

func _init():
	super._init()
	resource_name = "Select Settings"
