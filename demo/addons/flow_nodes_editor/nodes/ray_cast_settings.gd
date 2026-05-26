@tool
class_name RayCastNodeSettings
extends NodeSettings

@export_group("RayCast")

enum eDirectionMode {
	Constant,
	FromAttribute,
}

@export var dir : Vector3 = Vector3.DOWN
@export var max_distance : float = 1e3
@export var direction_mode : eDirectionMode = eDirectionMode.Constant:
	set(value):
		value = clampi(value, 0, eDirectionMode.size() - 1)
		if direction_mode != value:
			direction_mode = value
			notify_property_list_changed()
@export var direction_attribute : String = "direction":
	set(value):
		direction_attribute = value.strip_edges()
		emit_changed()
@export var distance_attribute : String = "":
	set(value):
		distance_attribute = value.strip_edges()
		emit_changed()
@export var normalize_direction : bool = true

@export var from_attribute : String = "position"

@export_group("Collision")
@export var collision_mask : int = 1
@export var collide_with_bodies : bool = true
@export var collide_with_areas : bool = false
@export var hit_from_inside : bool = false
@export var exclude_nodes_group : String = ""

@export_group("Outputs")
@export var out_result_attribute : String = "hit"
@export var out_position_attribute : String = "position"
@export var out_rotation_attribute : String = "rotation"
@export var out_normal_attribute : String = ""
@export var out_distance_attribute : String = ""
@export var out_collider_attribute : String = ""

func _init():
	super._init()
	resource_name = "RayCast Settings"

func exposeParam(name : String) -> bool:
	if name == "direction_attribute":
		return direction_mode == eDirectionMode.FromAttribute
	return true
