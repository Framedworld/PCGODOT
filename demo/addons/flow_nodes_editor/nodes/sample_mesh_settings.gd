@tool
class_name SampleMeshNodeSettings
extends NodeSettings

@export_group("Sample Mesh")

enum eMode {
	UseDensity,
	UseNumSamples,
	OnePerVertex,
	FaceCenters,
}

@export var mode : eMode = eMode.UseDensity
@export var density : float = 0.5
@export var num_samples : int = 100
@export var point_size : float = 1.0

@export_group("Hard Edges")
@export var discard_hard_edges : bool = false:
	set( new_value ):
		discard_hard_edges = new_value
		notify_property_list_changed()
@export var hard_edge_angle_threshold : float = 45.0
@export var hard_edge_distance_threshold : float = 0.1

func _init():
	super._init()
	resource_name = "Sample Mesh Settings"

func exposeParam( name : String ) -> bool:
	if name == "hard_edge_angle_threshold" or name == "hard_edge_distance_threshold":
		return discard_hard_edges
	if name == "density":
		return mode == eMode.UseDensity
	if name == "num_samples":
		return mode == eMode.UseNumSamples
	return true
