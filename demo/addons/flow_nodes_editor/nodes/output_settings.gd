@tool
class_name OutputNodeSettings
extends NodeSettings

@export_group("Output")

@export var name : String = "out_val"
@export var data_type : FlowData.DataType = FlowData.DataType.Float

func _init():
	super._init()
	resource_name = "Output"
