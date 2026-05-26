@tool
extends NodeSettings

@export_group("Mutate Seed")

enum eMode {
	Replace,
	Add,
	Xor,
}

@export var in_seed_attribute : String = "seed":
	set(value):
		in_seed_attribute = value.strip_edges()
		emit_changed()

@export var out_seed_attribute : String = "seed":
	set(value):
		out_seed_attribute = value.strip_edges()
		emit_changed()

@export var mode : eMode = eMode.Replace:
	set(value):
		value = clampi(value, 0, eMode.size() - 1)
		mode = value
		emit_changed()

@export var seed_offset : int = 1:
	set(value):
		seed_offset = value
		emit_changed()

@export var include_position : bool = true:
	set(value):
		include_position = value
		emit_changed()

func _init():
	super._init()
	resource_name = "Mutate Seed Settings"
