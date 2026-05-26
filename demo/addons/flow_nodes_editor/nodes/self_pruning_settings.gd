@tool
class_name SelfPruningSettings
extends NodeSettings

@export_group("Self Pruning")

enum ePruneMode {
	BoundsOverlap,
	GridCell,
}

@export var mode : ePruneMode = ePruneMode.BoundsOverlap:
	set(value):
		mode = value
		notify_property_list_changed()
		emit_changed()

@export var keep_self_intersections : bool = false
@export var cell_size : float = 1.0:
	set(value):
		cell_size = value
		emit_changed()
@export var prefer_attribute : String:
	set(value):
		prefer_attribute = value
		emit_changed()
@export var prefer_value : String:
	set(value):
		prefer_value = value
		emit_changed()

func _init():
	super._init()
	resource_name = "Self Pruning"

func exposeParam(name : String) -> bool:
	if mode == ePruneMode.BoundsOverlap:
		return name != "cell_size" and name != "prefer_attribute" and name != "prefer_value"
	return name != "keep_self_intersections"
