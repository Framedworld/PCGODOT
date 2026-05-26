@tool
class_name FilterDataByAttributeNodeSettings
extends NodeSettings

@export_group("Filter Data By Attribute")

@export var attribute_name: String = ""

func _init():
	super._init()
	resource_name = "Filter Data By Attribute Settings"
