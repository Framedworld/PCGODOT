@tool
extends "res://addons/flow_nodes_editor/nodes/difference.gd"

func _init():
	meta_node = {
		"title" : "Intersection",
		"settings" : DifferenceNodeSettings,
		"ins" : [{ "label": "In A" }, { "label": "In B" }],
		"outs" : [{ "label" : "Out" }],
		"hide_inputs" : true,
		"tooltip" : "Returns points in A that overlap points in B (UE-style Intersection alias).",
	}

func execute(ctx : FlowData.EvaluationContext):
	settings.operation = DifferenceNodeSettings.eOperation.Intersection
	super.execute(ctx)
