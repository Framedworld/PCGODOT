@tool
extends NodeSettings

@export_group("Clip Points By Polygon")

enum ePlane {
	XZ,
	XY,
	YZ,
}

@export var plane : ePlane = ePlane.XZ
@export var keep_inside : bool = true
@export var polygon_node_path : NodePath
@export var spline_stream_attribute : String = "node"

func _init():
	super._init()
	resource_name = "Clip Points By Polygon Settings"
