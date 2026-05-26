@tool
extends NodeSettings

@export_group("Attribute Set To Point")

@export var position_attribute_name : String = "position":
	set(value):
		position_attribute_name = value.strip_edges()
		emit_changed()

@export var rotation_attribute_name : String = "rotation":
	set(value):
		rotation_attribute_name = value.strip_edges()
		emit_changed()

@export var size_attribute_name : String = "size":
	set(value):
		size_attribute_name = value.strip_edges()
		emit_changed()

@export var use_defaults_when_missing : bool = true:
	set(value):
		use_defaults_when_missing = value
		emit_changed()

@export var default_position : Vector3 = Vector3.ZERO:
	set(value):
		default_position = value
		emit_changed()

@export var default_rotation : Vector3 = Vector3.ZERO:
	set(value):
		default_rotation = value
		emit_changed()

@export var default_size : Vector3 = Vector3.ONE:
	set(value):
		default_size = value
		emit_changed()

func _init():
	super._init()
	resource_name = "Attribute Set To Point Settings"
