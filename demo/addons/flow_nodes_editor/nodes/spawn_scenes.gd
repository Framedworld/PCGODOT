@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Spawn Scenes",
		"settings" : SpawnScenesNodeSettings,
		"ins" : [{ "label" : "In" }],
		"outs" : [{ "label" : "Out" }],
		"is_final" : true,
		"tooltip" : "Similar to spawn meshes but a full scene is instantiated on each node.\nA set of properties can be transfered from the nodes to each instanced scene.",
	}

func _exit_tree():
	#removeInstancedComponents();
	pass
	
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

	if in_data.size() == 0:
		set_output(0, in_data)
		return

	var scenes = null
	if settings.scene_attribute:
		var stream_scenes = in_data.findStream( settings.scene_attribute )
		if stream_scenes == null:
			setError( "Input does not have attribute '%s'" % settings.scene_attribute)
			return
		if stream_scenes.data_type != FlowData.DataType.Resource:
			setError( "Attribute '%s' should be of type Resource Packed Scene" % settings.scene_attribute)
			return
		scenes = stream_scenes.container
	
	var root = ctx.owner
	if not root:
		if Engine.is_editor_hint():
			set_output(0, in_data)
			return
		setError("Failed to find root")
		return

	var transforms = in_data.getTransformsStream()
	if transforms == null:
		setError("Missing required streams %s/%s" % [ FlowData.AttrPosition, FlowData.AttrRotation ])
		return
		
	var in_size = in_data.size()
	removeInstancedNodes( root )

	# Find who is going to be the owner of the new nodes
	# (shoulw be the parent root of the scene, not the parent)
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
		# Fallback: find the top-most node with an owner
		owner_of_spawned_nodes = root
		while owner_of_spawned_nodes.get_parent() and owner_of_spawned_nodes.owner:
			owner_of_spawned_nodes = owner_of_spawned_nodes.get_parent()

	var streams_to_assign = []
	for node_property in settings.assign_attributes:
		var stream_name = settings.assign_attributes[ node_property ]
		var stream = in_data.findStream( stream_name )
		if stream:
			streams_to_assign.append( { "node_property" : node_property, "container" : stream.container } )
	#print( streams_to_assign )

	# Collect which indices use the same by resource type
	for idx in range( in_size ):
		var packed_scene : PackedScene = scenes[idx] if scenes else settings.scene
		if not packed_scene:
			continue
		var node : Node3D = packed_scene.instantiate()
		node.transform = transforms.atIndex( idx )
		node.name = "Scene_%04d" % idx
		root.add_child( node )
		node.owner = owner_of_spawned_nodes
		node.set_meta("flow_owner", name )
		for s in streams_to_assign:
			node.set( s.node_property, s.container[ idx ])
	
	EditorInterface.mark_scene_as_unsaved()

	set_output(0, in_data)
