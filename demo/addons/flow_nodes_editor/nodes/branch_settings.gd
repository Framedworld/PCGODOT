@tool
class_name BranchNodeSettings
extends NodeSettings

@export_group("Branch")

@export var branch_value: bool = true
@export var use_attribute: bool = false
@export var attribute_name: String = ""

func _init():
	super._init()
	resource_name = "Branch Settings"
