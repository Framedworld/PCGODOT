@tool
class_name SurfaceSamplerNodeSettings
extends NodeSettings

@export_group("Surface Sampler")
@export var num_points: int = 40
@export var point_size: Vector3 = Vector3.ONE

func _init():
	super._init()
	resource_name = "Surface Sampler Settings"
