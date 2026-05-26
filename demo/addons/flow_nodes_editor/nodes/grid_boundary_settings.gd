@tool
class_name GridBoundaryNodeSettings
extends NodeSettings

@export_group("Grid Boundary")

@export var cell_size : Vector3 = Vector3.ONE:
	set(value):
		cell_size = value
		emit_changed()
@export var wall_thickness : float = 0.2:
	set(value):
		wall_thickness = maxf(0.0001, value)
		emit_changed()
@export var wall_height : float = 1.0:
	set(value):
		wall_height = maxf(0.0001, value)
		emit_changed()
@export var include_corners : bool = true:
	set(value):
		include_corners = value
		emit_changed()
@export var type_attribute : String = "boundary_type":
	set(value):
		type_attribute = value.strip_edges()
		emit_changed()
@export var normal_attribute : String = "boundary_normal":
	set(value):
		normal_attribute = value.strip_edges()
		emit_changed()

func _init():
	super._init()
	resource_name = "Grid Boundary"
