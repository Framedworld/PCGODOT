@tool
extends NodeSettings

@export_group("Split Splines")

@export var spline_stream_attribute : String = "node"
@export var uniform_interval : float = 1.0
@export var segment_size_xy : Vector2 = Vector2.ONE
@export var out_segment_index_attribute : String = "segment_index"
@export var out_spline_index_attribute : String = "spline_index"
@export var out_start_attribute : String = "segment_start"
@export var out_end_attribute : String = "segment_end"
@export var include_spline_ref : bool = true
@export var out_spline_attribute : String = "node"

func _init():
	super._init()
	resource_name = "Split Splines Settings"

func exposeParam(name : String) -> bool:
	if name == "out_spline_attribute":
		return include_spline_ref
	return true
