@tool
class_name InputNodeSettings
extends NodeSettings

@export_group("Input")

@export var name : String = "in_val"
@export var data_type : FlowData.DataType = FlowData.DataType.Float

func _init():
	super._init()
	resource_name = "Input"
