@tool
extends "res://addons/flow_nodes_editor/nodes/tags_mutate.gd"

func _init():
	meta_node = {
		"title" : "Delete Tags",
		"settings" : TagsMutateSettings,
		"ins" : [{ "label": "In" }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Removes one or more tags from FlowData.",
	}

func execute(ctx : FlowData.EvaluationContext):
	settings.operation = TagsMutateSettings.eOperation.Remove
	super.execute(ctx)
