@tool
extends "res://addons/flow_nodes_editor/nodes/tags_mutate.gd"

func _init():
	meta_node = {
		"title" : "Replace Tags",
		"settings" : TagsMutateSettings,
		"ins" : [{ "label": "In" }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Replaces all FlowData tags with the provided set.",
	}

func execute(ctx : FlowData.EvaluationContext):
	settings.operation = TagsMutateSettings.eOperation.Replace
	super.execute(ctx)
