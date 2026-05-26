@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Distance",
		"settings" : DistanceNodeSettings,
		"ins" : [{ "label": "In" }, { "label": "Target" }], 
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Creates a new attribute where the value is\nthe minimum distance from each point to any of the points in the second set.\nThe value can be normalized to an optional Max Distance",
	}

func execute( ctx : FlowData.EvaluationContext ):
	
	if not settings.out_name:
		setError( "Output name can't be empty")
		return
		
	var in_dataA : FlowData.Data = get_input(0)
	if not in_dataA.hasStreamOfType( settings.in_nameA, FlowData.DataType.Vector ):
		if ctx.owner == null and Engine.is_editor_hint():
			var empty_data = FlowData.Data.new()
			set_output(0, empty_data)
			return
		setError( "Input A %s not found" % [settings.in_nameA])
		return
		
	var in_dataB : FlowData.Data = get_input(1)
	if not  in_dataB.hasStreamOfType( settings.in_nameB, FlowData.DataType.Vector ):
		if ctx.owner == null and Engine.is_editor_hint():
			var empty_data = FlowData.Data.new()
			set_output(0, empty_data)
			return
		setError( "Input B %s not found" % [settings.in_nameB])
		return
		
	var sA := in_dataA.getVector3Container( settings.in_nameA )
	var sB := in_dataB.getVector3Container( settings.in_nameB )
		
	var size_A = in_dataA.size()
		
	var kdtree = GDKdTree.new()
	kdtree.set_points( sB )
	#print( "Populated kdtree with %d points. WIll check %d" % [in_dataB.size(), size_A])
	var nearest_indices : PackedInt32Array = kdtree.find_nearest_indices( sA )
	
	var inv_max_distance : float = 1.0 / settings.max_distance if settings.max_distance > 0 else 1.0
	
	var out_data : FlowData.Data = in_dataA.duplicate()
	var out_container := PackedFloat32Array()
	out_container.resize( size_A )
	for idx in range(size_A):
		var idxB := nearest_indices[ idx ]
		var delta := sA[ idx ] - sB[ idxB ]
		out_container[ idx ] = delta.length() * inv_max_distance
	
	var err = out_data.registerStream( settings.out_name, out_container )
	set_output( 0, out_data )
