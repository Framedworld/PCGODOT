@tool
extends NodeSettings

@export_group("Point From Player Pawn")

@export_node_path("Node3D") var player_node_path : NodePath
@export var group_name : String = "player"
@export var class_name_filter : String = "CharacterBody3D"
@export var name_pattern : String = "*"
@export var include_node_ref : bool = true
@export var node_attribute : String = "node"

func _init():
	super._init()
	resource_name = "Point From Player Pawn Settings"

func exposeParam(name : String) -> bool:
	if name == "node_attribute":
		return include_node_ref
	return true
