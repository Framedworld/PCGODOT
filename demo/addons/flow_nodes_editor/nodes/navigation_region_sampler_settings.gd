@tool
extends NodeSettings

@export_group("Navigation Region Sampler")

enum eSampleMode {
	Polygons,
	Vertices,
}

@export_node_path("NavigationRegion3D") var navigation_region_path : NodePath
@export var group_name : String = ""
@export var sample_mode : eSampleMode = eSampleMode.Polygons
@export var point_size : Vector3 = Vector3.ONE
@export var out_region_attribute : String = "navigation_region"
@export var out_polygon_index_attribute : String = "navigation_polygon_index"
@export var out_area_attribute : String = "navigation_polygon_area"

func _init():
	super._init()
	resource_name = "Navigation Region Sampler Settings"
