@tool
class_name SpawnNodesNodeSettings
extends NodeSettings

@export_group("Spawn Nodes")

@export var node_class : String = "OmniLight3D"
@export var assign_attributes: Dictionary

func _init():
	super._init()
	resource_name = "Spawn Nodes Settings"
