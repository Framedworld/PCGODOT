@tool
class_name DecomposeVectorNodeSettings
extends NodeSettings

@export_group("Decompose Vector")
@export var in_attribute: String = "position"
@export var x_attribute: String = "x"
@export var y_attribute: String = "y"
@export var z_attribute: String = "z"

func _init():
	super._init()
	resource_name = "Decompose Vector Settings"
