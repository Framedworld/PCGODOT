@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Spawn Meshes",
		"settings" : SpawnMeshesNodeSettings,
		"ins" : [{ "label" : "In" }],
		"outs" : [{ "label" : "Out" }],
		"is_final" : true,
		"tooltip" : "Spawns a Mesh Instance on each point, applying the translation, rotation and scale.\nThe instanced mesh can be specified by point if a stream contains the mesh resource to be spawned.\nThe generates meshes are MultiMeshInstance3D.",
	}

func _exit_tree():
	#removeInstancedComponents();
	pass
	
func removeInstancedComponents( root : Node3D ):
	var comps = []
	for child in root.get_children():
		var mmi = child as MultiMeshInstance3D
		if mmi and mmi.get_meta( "flow_owner" ) == name:
			comps.append( mmi )
	for comp in comps:
		comp.queue_free()
		
func spawnNode( root : Node, class_to_spawn ):
	var new_node = class_to_spawn.new()
	new_node.set_meta("flow_owner", name )	
	return new_node

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if !in_data:
		setError( "Input is invalid")
		return

	if in_data.size() == 0:
		set_output(0, in_data)
		return

	var meshes = null
	if settings.mesh_attribute:
		var stream_meshes = in_data.findStream( settings.mesh_attribute )
		if stream_meshes == null:
			setError( "Input does not have attribute '%s'" % settings.mesh_attribute)
			return
		if stream_meshes.data_type != FlowData.DataType.Resource:
			setError( "Attribute '%s' should be of type Resource" % settings.mesh_attribute)
			return
		meshes = stream_meshes.container
	
	var transforms := in_data.getTransformsStream()
	if transforms == null:
		setError("Missing transforms information")
		return

	var root = ctx.owner
	if not root:
		if Engine.is_editor_hint():
			set_output(0, in_data)
			return
		setError("Failed to find root")
		return
		
	var in_size = in_data.size()
	removeInstancedComponents( root )

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
		
	var owner_of_mmis : Node
	if scene_root:
		owner_of_mmis = scene_root
	else:
		# Fallback: find the top-most node with an owner
		owner_of_mmis = root
		while owner_of_mmis.get_parent() and owner_of_mmis.owner:
			owner_of_mmis = owner_of_mmis.get_parent()

	var default_mesh = getSettingValue(ctx, "mesh")

	# Collect which indices use the samee by resource type
	var mmis := {}
	for idx in range( in_size ):
		var mesh = meshes[idx] if meshes else default_mesh
		#print( "Meshes[%d] is %s" % [ idx, mesh ])
		if mesh == null:
			continue
		var key = mesh.resource_path
		if key == null or not key:
			continue
		#print( "Meshes[%d].key is %s" % [ idx, key ])
		var mmi = mmis.get( key, null )
		if mmi == null:
			mmis[ key ] = []
		mmis[ key ].append( idx )
	
	#print( "mmis: ", mmis )
	var color_stream = in_data.findStream("color")
	var has_colors = color_stream != null and color_stream.data_type == FlowData.DataType.Color

	for res in mmis.keys():
		var mmi : MultiMeshInstance3D = spawnNode( root, MultiMeshInstance3D )
		
		var multimesh := MultiMesh.new()
		multimesh.mesh = load( res )
		multimesh.transform_format = MultiMesh.TransformFormat.TRANSFORM_3D
		if has_colors:
			multimesh.use_colors = true
		var ids = mmis[res]
		multimesh.instance_count = ids.size()
		
		# We could also create a large buffer and perform a single update
		var idx := 0
		for id in ids:
			multimesh.set_instance_transform( idx, transforms.atIndex( id ) )
			if has_colors:
				multimesh.set_instance_color( idx, color_stream.container[id] )
			idx += 1
			
		mmi.multimesh = multimesh
		if has_colors:
			var mat = StandardMaterial3D.new()
			mat.vertex_color_use_as_albedo = true
			mat.roughness = 0.3
			mmi.material_override = mat
		root.add_child( mmi )
		mmi.owner = owner_of_mmis
	
	EditorInterface.mark_scene_as_unsaved()

	set_output(0, in_data)
