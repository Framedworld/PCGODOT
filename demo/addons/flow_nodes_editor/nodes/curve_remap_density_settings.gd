@tool
class_name CurveRemapDensityNodeSettings
extends NodeSettings

@export_group("Curve Remap Density")

@export var remap_curve: Curve

func _init():
	super._init()
	resource_name = "Curve Remap Density Settings"
