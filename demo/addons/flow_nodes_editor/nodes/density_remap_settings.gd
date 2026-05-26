@tool
class_name DensityRemapNodeSettings
extends NodeSettings

@export_group("Density Remap")

@export var in_min: float = 0.0
@export var in_max: float = 1.0
@export var out_min: float = 0.0
@export var out_max: float = 1.0
@export var clamp_to_output_range: bool = true

func _init():
	super._init()
	resource_name = "Density Remap Settings"
