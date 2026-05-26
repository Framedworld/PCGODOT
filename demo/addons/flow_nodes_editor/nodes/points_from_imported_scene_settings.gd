@tool
extends NodeSettings

@export_group("Points From Imported Scene")

@export_file("*.tscn", "*.scn", "*.glb", "*.gltf", "*.obj", "*.fbx", "*.abc", "*.mesh", "*.res", "*.tres") var asset_path : String = ""
@export var use_mesh_bounds : bool = true
@export var fallback_size : Vector3 = Vector3.ONE
@export var include_mesh_resource : bool = true
@export var mesh_attribute : String = "mesh"
@export var include_source_name : bool = true
@export var source_name_attribute : String = "source_node_name"
@export var include_source_path : bool = true
@export var source_path_attribute : String = "source_path"

func _init():
	super._init()
	resource_name = "Points From Imported Scene Settings"

func exposeParam(name : String) -> bool:
	if name == "mesh_attribute":
		return include_mesh_resource
	if name == "source_name_attribute":
		return include_source_name
	if name == "source_path_attribute":
		return include_source_path
	return true
