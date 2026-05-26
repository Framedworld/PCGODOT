@tool
class_name BuildRotationFromUpNodeSettings
extends NodeSettings

@export_group("Build Rotation From Up Vector")

@export var up_vector_attribute: String = "normal"
@export var up_vector_constant: Vector3 = Vector3.UP
@export var use_constant: bool = false
@export var axis: String = "z"

func _init():
	super._init()
	resource_name = "Build Rotation From Up Vector Settings"
