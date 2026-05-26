@tool
class_name BoundsModifierNodeSettings
extends NodeSettings

@export_group("Bounds Modifier")

enum eMode { Set, Add, Multiply }
@export var mode: eMode = eMode.Set
@export var bounds_min: Vector3 = -Vector3.ONE * 0.5
@export var bounds_max: Vector3 = Vector3.ONE * 0.5

func _init():
	super._init()
	resource_name = "Bounds Modifier Settings"
