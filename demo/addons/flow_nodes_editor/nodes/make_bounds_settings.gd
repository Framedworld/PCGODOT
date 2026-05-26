@tool
class_name MakeBoundsNodeSettings
extends NodeSettings

@export_group("Make Bounds")
@export var size: Vector3 = Vector3(48.0, 1.0, 48.0)
@export var center: Vector3 = Vector3.ZERO

func _init():
	super._init()
	resource_name = "Make Bounds Settings"
