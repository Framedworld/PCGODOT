@tool
class_name SubgraphNodeSettings
extends NodeSettings

@export_group("Subgraph")

@export var graph : FlowGraphResource:
	set(value):
		graph = value
		emit_changed()

func _init():
	super._init()
	resource_name = "Subgraph"
