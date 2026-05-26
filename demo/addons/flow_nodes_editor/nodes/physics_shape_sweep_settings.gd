@tool
extends NodeSettings

@export_group("Physics Shape Sweep")

enum eShapeType {
	Sphere,
	Box,
}

enum eDirectionMode {
	Constant,
	FromAttribute,
}

@export var shape_type : eShapeType = eShapeType.Sphere:
	set(value):
		value = clampi(value, 0, eShapeType.size() - 1)
		shape_type = value
		notify_property_list_changed()

@export var radius : float = 0.5
@export var half_extents : Vector3 = Vector3.ONE
@export var use_point_size_for_shape : bool = false
@export var position_attribute : String = "position"
@export var direction_mode : eDirectionMode = eDirectionMode.Constant:
	set(value):
		value = clampi(value, 0, eDirectionMode.size() - 1)
		direction_mode = value
		notify_property_list_changed()
@export var direction : Vector3 = Vector3.FORWARD
@export var direction_attribute : String = "direction"
@export var distance : float = 10.0
@export var distance_attribute : String = ""

@export_group("Collision")
@export var collision_mask : int = 1
@export var collide_with_bodies : bool = true
@export var collide_with_areas : bool = false
@export var exclude_nodes_group : String = ""

@export_group("Outputs")
@export var out_hit_attribute : String = "sweep_hit"
@export var out_position_attribute : String = "position"
@export var out_safe_fraction_attribute : String = "sweep_safe_fraction"
@export var out_unsafe_fraction_attribute : String = "sweep_unsafe_fraction"
@export var out_collider_attribute : String = ""

func _init():
	super._init()
	resource_name = "Physics Shape Sweep Settings"

func exposeParam(name : String) -> bool:
	if name == "radius":
		return shape_type == eShapeType.Sphere and not use_point_size_for_shape
	if name == "half_extents":
		return shape_type == eShapeType.Box and not use_point_size_for_shape
	if name == "direction_attribute":
		return direction_mode == eDirectionMode.FromAttribute
	return true
