@tool
extends "res://addons/flow_nodes_editor/nodes/sample_mesh.gd"

const SampleMeshNodeSettings = preload("res://addons/flow_nodes_editor/nodes/sample_mesh_settings.gd")

func _init():
	meta_node = {
		"title" : "Mesh Sampler",
		"settings" : SampleMeshNodeSettings,
		"ins" : [{ "label": "Meshes", "data_type": FlowData.DataType.NodeMesh }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Samples points on a mesh surface. Unreal-style alias of Sample Mesh.",
	}
