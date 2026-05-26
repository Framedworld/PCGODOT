@tool
extends NodeSettings

@export_group("Physics Overlap Query")

enum eShapeType {
	Sphere,
	Box,
}

@export var shape_type : eShapeType = eShapeType.Sphere:
	set(value):
		value = clampi(value, 0, eShapeType.size() - 1)
		if shape_type != value:
			shape_type = value
			notify_property_list_changed()

@export var radius : float = 1.0
@export var half_extents : Vector3 = Vector3.ONE
@export var use_point_size_for_shape : bool = false
@export var position_attribute : String = "position"

@export_group("Collision")
@export var collision_mask : int = 1
@export var collide_with_bodies : bool = true
@export var collide_with_areas : bool = false
@export var max_results : int = 8
@export var exclude_nodes_group : String = ""

@export_group("Outputs")
@export var out_hit_attribute : String = "overlap_hit"
@export var out_count_attribute : String = "overlap_count"
@export var out_first_collider_attribute : String = ""

func _init():
	super._init()
	resource_name = "Physics Overlap Query Settings"

func exposeParam(name : String) -> bool:
	if name == "radius":
		return shape_type == eShapeType.Sphere and not use_point_size_for_shape
	if name == "half_extents":
		return shape_type == eShapeType.Box and not use_point_size_for_shape
	return true
