@tool
extends NodeSettings

@export_group("Texture Sampler")

enum eWrapMode {
	Wrap,
	Clamp,
}

enum eValueChannel {
	R,
	G,
	B,
	A,
	Luminance,
}

@export var texture : Texture2D:
	set(value):
		texture = value
		emit_changed()

@export var uv_attribute_name : String = "uv":
	set(value):
		uv_attribute_name = value.strip_edges()
		emit_changed()

@export var position_attribute_name : String = "position":
	set(value):
		position_attribute_name = value.strip_edges()
		emit_changed()

@export var use_position_if_uv_missing : bool = true:
	set(value):
		if use_position_if_uv_missing != value:
			use_position_if_uv_missing = value
			notify_property_list_changed()

@export var use_xz_for_position : bool = true:
	set(value):
		use_xz_for_position = value
		emit_changed()

@export var uv_scale : Vector2 = Vector2(0.1, 0.1):
	set(value):
		uv_scale = value
		emit_changed()

@export var uv_offset : Vector2 = Vector2.ZERO:
	set(value):
		uv_offset = value
		emit_changed()

@export var wrap_mode : eWrapMode = eWrapMode.Wrap:
	set(value):
		value = clampi(value, 0, eWrapMode.size() - 1)
		wrap_mode = value
		emit_changed()

@export_group("Outputs")
@export var write_color_attribute : bool = true:
	set(value):
		if write_color_attribute != value:
			write_color_attribute = value
			notify_property_list_changed()

@export var out_color_attribute_name : String = "sampled_color":
	set(value):
		out_color_attribute_name = value.strip_edges()
		emit_changed()

@export var write_value_attribute : bool = true:
	set(value):
		if write_value_attribute != value:
			write_value_attribute = value
			notify_property_list_changed()

@export var out_value_attribute_name : String = "sampled_value":
	set(value):
		out_value_attribute_name = value.strip_edges()
		emit_changed()

@export var value_channel : eValueChannel = eValueChannel.Luminance:
	set(value):
		value = clampi(value, 0, eValueChannel.size() - 1)
		value_channel = value
		emit_changed()

func _init():
	super._init()
	resource_name = "Texture Sampler Settings"

func exposeParam(name : String) -> bool:
	if name == "position_attribute_name" or name == "use_xz_for_position" or name == "uv_scale" or name == "uv_offset":
		return use_position_if_uv_missing
	if name == "out_color_attribute_name":
		return write_color_attribute
	if name == "out_value_attribute_name" or name == "value_channel":
		return write_value_attribute
	return true
