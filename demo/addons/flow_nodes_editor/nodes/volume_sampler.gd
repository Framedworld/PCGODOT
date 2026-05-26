@tool
extends "res://addons/flow_nodes_editor/nodes/sample_points.gd"

const VolumeSamplerNodeSettings = preload("res://addons/flow_nodes_editor/nodes/volume_sampler_settings.gd")

func _init():
	meta_node = {
		"title" : "Volume Sampler",
		"settings" : VolumeSamplerNodeSettings,
		"ins" : [{ "label" : "In" }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Samples points inside incoming point volumes (UE-style Volume Sampler alias).",
	}
