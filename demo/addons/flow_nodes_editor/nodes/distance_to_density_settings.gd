@tool
class_name DistanceToDensityNodeSettings
extends NodeSettings

@export_group("Distance to Density")

@export var reference_position: Vector3 = Vector3.ZERO
@export var min_distance: float = 0.0
@export var max_distance: float = 10.0
@export var min_density: float = 0.0
@export var max_density: float = 1.0
@export var invert: bool = false

func _init():
	super._init()
	resource_name = "Distance to Density Settings"
