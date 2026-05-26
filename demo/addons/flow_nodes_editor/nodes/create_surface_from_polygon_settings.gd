@tool
extends NodeSettings

@export_group("Create Surface From Polygon")

enum ePlane {
	XZ,
	XY,
	YZ,
}

@export var plane : ePlane = ePlane.XZ
@export var group_attribute : String = ""
@export var minimum_thickness : float = 0.1
@export var out_area_attribute : String = "surface_area"
@export var out_perimeter_attribute : String = "surface_perimeter"
@export var out_point_count_attribute : String = "surface_point_count"

func _init():
	super._init()
	resource_name = "Create Surface From Polygon Settings"
