@tool
class_name CopyNodeSettings
extends NodeSettings

@export_group("Copy")

enum eMode {
	LinearCopies,
	SourceToTargets,
}

enum eSourceSelection {
	Cycle,
	RandomDeterministic,
}

@export var mode : eMode = eMode.LinearCopies:
	set(value):
		value = clampi(value, 0, eMode.size() - 1)
		if mode != value:
			mode = value
			notify_property_list_changed()

@export var num_copies := 1:
	set(value):
		num_copies = maxi(0, value)
		emit_changed()
@export var translation : Vector3 = Vector3.ZERO
@export var rotation : Vector3 = Vector3.ZERO

@export var source_selection : eSourceSelection = eSourceSelection.Cycle:
	set(value):
		value = clampi(value, 0, eSourceSelection.size() - 1)
		source_selection = value
		emit_changed()
@export var combine_source_with_target_transform : bool = true
@export var inherit_target_scale : bool = true
@export var write_target_index_attribute : String = ""

@export var generate_copy_id : String

func _init():
	super._init()
	resource_name = "Copy Settings"

func exposeParam(name : String) -> bool:
	if mode == eMode.LinearCopies:
		if name == "source_selection" or name == "combine_source_with_target_transform" or name == "inherit_target_scale" or name == "write_target_index_attribute":
			return false
		return true

	if name == "num_copies" or name == "translation" or name == "rotation":
		return false
	return true
