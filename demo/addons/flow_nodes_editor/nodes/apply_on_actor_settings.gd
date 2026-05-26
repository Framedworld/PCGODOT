@tool
extends NodeSettings

@export_group("Apply On Actor")

enum eTargetMode {
	FromNodeStream,
	NodePath,
	Group,
}

@export var target_mode : eTargetMode = eTargetMode.FromNodeStream:
	set(value):
		value = clampi(value, 0, eTargetMode.size() - 1)
		target_mode = value
		notify_property_list_changed()

@export var target_stream_attribute : String = "node"
@export_node_path("Node") var target_node_path : NodePath
@export var group_name : String = ""
@export_node_path("Node") var target_child_path : NodePath
@export var apply_transform_to_node3d : bool = false
@export var assign_attributes : Dictionary = {}

func _init():
	super._init()
	resource_name = "Apply On Actor Settings"

func exposeParam(name : String) -> bool:
	if name == "target_stream_attribute":
		return target_mode == eTargetMode.FromNodeStream
	if name == "target_node_path":
		return target_mode == eTargetMode.NodePath
	if name == "group_name":
		return target_mode == eTargetMode.Group
	return true
