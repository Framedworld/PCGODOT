@tool
class_name PrintStringNodeSettings
extends NodeSettings

@export_group("Print String")

@export var prefix_message: String = "Log:"
@export var attribute_to_print: String = ""

func _init():
	super._init()
	resource_name = "Print String Settings"
