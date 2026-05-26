@tool
extends "res://addons/flow_nodes_editor/nodes/tags_mutate.gd"

func _init():
	meta_node = {
		"title" : "Add Tags",
		"settings" : TagsMutateSettings,
		"ins" : [{ "label": "In" }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Adds one or more tags to FlowData.",
	}

func execute(ctx : FlowData.EvaluationContext):
	settings.operation = TagsMutateSettings.eOperation.Add
	super.execute(ctx)
