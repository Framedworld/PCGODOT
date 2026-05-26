@tool
extends NodeSettings

@export_group("Create Surface From Spline")

enum ePlane {
	XZ,
	XY,
	YZ,
}

@export var spline_stream_attribute : String = "node"
@export var plane : ePlane = ePlane.XZ
@export var minimum_thickness : float = 0.1
@export var out_area_attribute : String = "surface_area"
@export var out_perimeter_attribute : String = "surface_perimeter"
@export var include_spline_ref : bool = true
@export var out_spline_attribute : String = "node"

func _init():
	super._init()
	resource_name = "Create Surface From Spline Settings"

func exposeParam(name : String) -> bool:
	if name == "out_spline_attribute":
		return include_spline_ref
	return true
