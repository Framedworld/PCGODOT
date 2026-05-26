@tool
class_name SnapToGridNodeSettings
extends NodeSettings

@export_group("Snap to Grid")
@export var grid_size: Vector3 = Vector3.ONE * 2.0
@export var snap_position: bool = true
@export var snap_rotation: bool = false
@export var snap_scale: bool = false

func _init():
	super._init()
	resource_name = "Snap to Grid Settings"
