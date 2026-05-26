@tool
class_name ComposeVectorNodeSettings
extends NodeSettings

@export_group("Compose Vector")
@export var x_attribute: String = ""
@export var y_attribute: String = ""
@export var z_attribute: String = ""
@export var default_value: Vector3 = Vector3.ONE
@export var out_attribute: String = "size"

func _init():
	super._init()
	resource_name = "Compose Vector Settings"
