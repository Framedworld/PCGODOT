@tool
class_name SpawnNodesNodeSettings
extends NodeSettings

@export_group("Spawn Nodes")

@export var node_class : String = "OmniLight3D"
@export var node_class_variants : Array[String] = []
@export var node_selector_attribute : String = ""
@export var randomize_node_variants : bool = false
@export var spawn_parent_path : String = ""
@export var clear_previous_instances : bool = true
@export var assign_target_path : String = ""
@export var assign_attributes: Dictionary

func _init():
	super._init()
	resource_name = "Spawn Nodes Settings"

func exposeParam(name : String) -> bool:
	if name == "node_selector_attribute":
		return node_class_variants.size() > 0 and not randomize_node_variants
	return true
