@tool
class_name GridConnectPointsNodeSettings
extends NodeSettings

@export_group("Grid Connect Points")

enum eAxisOrder {
	XThenZ,
	ZThenX,
}

@export var cell_size : Vector3 = Vector3.ONE:
	set(value):
		cell_size = value
		emit_changed()
@export var axis_order : eAxisOrder = eAxisOrder.XThenZ:
	set(value):
		axis_order = value
		emit_changed()
@export var include_input_points : bool = true:
	set(value):
		include_input_points = value
		emit_changed()
@export var deduplicate_cells : bool = true:
	set(value):
		deduplicate_cells = value
		emit_changed()
@export var path_index_attribute : String = "path_index":
	set(value):
		path_index_attribute = value.strip_edges()
		emit_changed()

func _init():
	super._init()
	resource_name = "Grid Connect Points"
