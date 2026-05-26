@tool
class_name SelectPointsNodeSettings
extends NodeSettings

@export_group("Select Points")

@export_range(0.0, 1.0) var ratio : float = 0.2
@export var weight_name : String

func _init():
	super._init()
	resource_name = "Select Points Settings"
