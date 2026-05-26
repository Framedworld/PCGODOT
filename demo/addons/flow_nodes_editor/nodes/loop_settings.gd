@tool
class_name LoopNodeSettings
extends NodeSettings

@export_group("Loop")

@export var graph : FlowGraphResource:
	set(value):
		graph = value
		emit_changed()
@export var item_input_name : String = "item":
	set(value):
		item_input_name = value
		emit_changed()
@export var output_attribute_name : String = "result":
	set(value):
		output_attribute_name = value
		emit_changed()

@export var feedback_param_name : String = "":
	set(value):
		feedback_param_name = value
		emit_changed()

func _init():
	super._init()
	resource_name = "Loop"

