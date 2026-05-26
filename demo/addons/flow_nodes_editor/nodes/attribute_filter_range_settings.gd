@tool
extends NodeSettings

@export_group("Attribute Filter Range")
@export var attribute_name : String = "":
	set(value):
		attribute_name = value.strip_edges()
		emit_changed()

@export var min_value : float = 0.0:
	set(value):
		min_value = value
		emit_changed()

@export var max_value : float = 1.0:
	set(value):
		max_value = value
		emit_changed()

@export var inclusive_min : bool = true:
	set(value):
		inclusive_min = value
		emit_changed()

@export var inclusive_max : bool = true:
	set(value):
		inclusive_max = value
		emit_changed()

@export var use_absolute_value : bool = false:
	set(value):
		use_absolute_value = value
		emit_changed()

func _init():
	super._init()
	resource_name = "Attribute Filter Range Settings"
