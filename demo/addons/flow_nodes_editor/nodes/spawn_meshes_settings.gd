@tool
class_name SpawnMeshesNodeSettings
extends NodeSettings

@export_group("Spawn Meshes")

@export var mesh : Mesh = preload( "res://addons/flow_nodes_editor/resources/unit_cube.tres" )
@export var mesh_attribute : String
@export var mesh_variants : Array[Mesh] = []
@export var mesh_variant_weights : Array[float] = []
@export var mesh_selector_attribute : String = ""
@export var randomize_mesh_variants : bool = false
@export var color_attribute : String = "color"
@export var use_vertex_colors : bool = true
@export var spawn_parent_path : String = ""
@export var clear_previous_instances : bool = true

func _init():
	super._init()
	resource_name = "Spawn Meshes Settings"

func exposeParam(name : String) -> bool:
	if name == "mesh_variant_weights":
		return mesh_variants.size() > 0
	if name == "mesh_selector_attribute":
		return mesh_variants.size() > 0 and not randomize_mesh_variants
	return true
