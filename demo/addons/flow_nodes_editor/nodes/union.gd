@tool
extends "res://addons/flow_nodes_editor/nodes/difference.gd"

func _init():
	meta_node = {
		"title" : "Union",
		"settings" : DifferenceNodeSettings,
		"ins" : [{ "label": "In A" }, { "label": "In B" }],
		"outs" : [{ "label" : "Out" }],
		"hide_inputs" : true,
		"tooltip" : "UE-style Union alias. Merges all incoming point sets.",
	}

func execute(ctx : FlowData.EvaluationContext):
	settings.operation = DifferenceNodeSettings.eOperation.Union
	super.execute(ctx)
