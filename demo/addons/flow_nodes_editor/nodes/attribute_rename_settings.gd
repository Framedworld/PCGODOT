@tool
extends NodeSettings

@export_group("Attribute Rename")
@export var from_name : String = "":
	set(value):
		from_name = value.strip_edges()
		emit_changed()

@export var to_name : String = "":
	set(value):
		to_name = value.strip_edges()
		emit_changed()

@export var overwrite_existing : bool = false:
	set(value):
		overwrite_existing = value
		emit_changed()

func _init():
	super._init()
	resource_name = "Attribute Rename Settings"
