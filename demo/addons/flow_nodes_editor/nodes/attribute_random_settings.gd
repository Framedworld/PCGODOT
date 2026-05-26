@tool
class_name AttributeRandomNodeSettings
extends NodeSettings

@export_group("Attribute Random")
@export var attribute_name: String = "random_attr"

enum eType { Float, Int }
@export var data_type: eType = eType.Float

@export var min_value: float = 0.0
@export var max_value: float = 1.0

@export var use_index_as_value: bool = false

func _init():
	super._init()
	resource_name = "Attribute Random Settings"
