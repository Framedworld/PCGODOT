@tool
class_name SpawnScenesNodeSettings
extends NodeSettings

@export_group("Spawn Scenes")

@export var scene : PackedScene
@export var scene_attribute : String
@export var scene_variants : Array[PackedScene] = []
@export var scene_variant_weights : Array[float] = []
@export var scene_selector_attribute : String = ""
@export var randomize_scene_variants : bool = false
@export var spawn_parent_path : String = ""
@export var clear_previous_instances : bool = true
@export var assign_target_path : String = ""
@export var assign_attributes: Dictionary

func _init():
	super._init()
	resource_name = "Spawn Scenes Settings"

func exposeParam(name : String) -> bool:
	if name == "scene_variant_weights":
		return scene_variants.size() > 0
	if name == "scene_selector_attribute":
		return scene_variants.size() > 0 and not randomize_scene_variants
	return true
