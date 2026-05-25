@tool
extends FlowNodeBase

const SpawnNodesNodeSettings = preload("res://addons/flow_nodes_editor/nodes/spawn_nodes_settings.gd")

func _init():
	meta_node = {
		"title" : "Spawn Nodes",
		"settings" : SpawnNodesNodeSettings,
		"ins" : [{ "label" : "In" }],
		"outs" : [{ "label" : "Out" }],
		"is_final" : true,
		"tooltip" : "Dynamically instantiates a raw Godot class or custom script node on each point.\nProperties can be transferred from point attributes to node properties.",
	}

func removeInstancedNodes( root : Node3D ):
	var nodes : Array[Node] = []
	for child in root.get_children():
		if !child.has_meta( "flow_owner" ):
			continue
		if child.get_meta( "flow_owner" ) == name:
			nodes.append( child )
	for node in nodes:
		node.queue_free()

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if !in_data:
		setError( "Input is invalid")
		return

	var transforms = in_data.getTransformsStream()
	if transforms == null:
		setError("Missing required transforms stream")
		return

	var root = ctx.owner
	if not root:
		setError("Failed to find root")
		return
		
	var in_size = in_data.size()
	removeInstancedNodes( root )

	# Find who is going to be the owner of the new nodes
	var node_tree = root.get_tree()
	if not node_tree:
		setError("Invalid current scene")
		return
		
	var scene_root = node_tree.current_scene
	if not root.get_tree():
		setError("Invalid scene_root scene")
		return
		
	var owner_of_spawned_nodes : Node
	if scene_root:
		owner_of_spawned_nodes = scene_root
	else:
		owner_of_spawned_nodes = root
		while owner_of_spawned_nodes.get_parent() and owner_of_spawned_nodes.owner:
			owner_of_spawned_nodes = owner_of_spawned_nodes.get_parent()

	var class_name_to_spawn = settings.node_class.strip_edges()
	if class_name_to_spawn == "":
		setError("Node Class name cannot be empty")
		return

	# Helper to check if class exists and can be instantiated
	var is_script_path = class_name_to_spawn.begins_with("res://") and class_name_to_spawn.ends_with(".gd")
	if not is_script_path:
		if not ClassDB.class_exists(class_name_to_spawn):
			setError("Class '%s' does not exist in ClassDB" % class_name_to_spawn)
			return
		if not ClassDB.can_instantiate(class_name_to_spawn):
			setError("Class '%s' cannot be instantiated directly" % class_name_to_spawn)
			return

	# Setup property mapping streams
	var streams_to_assign = []
	for node_property in settings.assign_attributes:
		var stream_name = settings.assign_attributes[ node_property ]
		var stream = in_data.findStream( stream_name )
		if stream:
			streams_to_assign.append( { "node_property" : node_property, "container" : stream.container } )

	# Spawn nodes
	for idx in range( in_size ):
		var node : Node = null
		if is_script_path:
			var script = load(class_name_to_spawn)
			if script:
				node = script.new()
		else:
			node = ClassDB.instantiate(class_name_to_spawn)

		if not node:
			setError("Failed to instantiate '%s'" % class_name_to_spawn)
			return

		var node3d = node as Node3D
		if not node3d:
			node.queue_free()
			setError("Instantiated node '%s' is not a Node3D subclass" % class_name_to_spawn)
			return

		node3d.transform = transforms.atIndex( idx )
		node3d.name = "%s_%04d" % [class_name_to_spawn.get_file().get_basename(), idx]
		root.add_child( node3d )
		node3d.owner = owner_of_spawned_nodes
		node3d.set_meta("flow_owner", name )

		# Assign mapped attributes to properties
		for s in streams_to_assign:
			node3d.set( s.node_property, s.container[ idx ])
	
	EditorInterface.mark_scene_as_unsaved()
	set_output(0, in_data)
