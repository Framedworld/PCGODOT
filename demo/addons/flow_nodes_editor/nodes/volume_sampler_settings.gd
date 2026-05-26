@tool
extends "res://addons/flow_nodes_editor/nodes/sample_points_settings.gd"

func _init():
	super._init()
	resource_name = "Volume Sampler Settings"
	distribution = SamplePointsNodeSettings.eDistribution.UniformGrid
