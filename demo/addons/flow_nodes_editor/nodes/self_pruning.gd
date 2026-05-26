@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Self Pruning",
		"settings" : SelfPruningSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Rejects points that overlap previous points, or removes duplicate grid-cell points.",
	}

func execute( _ctx : FlowData.EvaluationContext ):
	var in_dataA: FlowData.Data = get_input(0)
	
	if in_dataA == null:
		setError( "Input not found")
		return

	if settings.mode == SelfPruningSettings.ePruneMode.GridCell:
		_grid_cell_prune(in_dataA)
		return
		
	var tA := GDRTree.new()
	var posA = in_dataA.getVector3Container( FlowData.AttrPosition )
	var szA = in_dataA.getVector3Container( FlowData.AttrSize )
	var result = tA.self_prune( posA, szA, settings.keep_self_intersections )
	
	var out_data : FlowData.Data = in_dataA.filter( result.idxs_overlapped )
		
	set_output( 0, out_data )

func _grid_cell_prune(in_data: FlowData.Data):
	var cell_size : float = settings.cell_size
	if cell_size <= 0.0:
		setError("Cell size must be greater than zero")
		return

	var positions = in_data.getVector3Container( FlowData.AttrPosition )
	if positions.is_empty():
		set_output(0, FlowData.Data.new())
		return

	var prefer_stream = null
	if settings.prefer_attribute != "":
		prefer_stream = in_data.findStream(settings.prefer_attribute)
		if prefer_stream == null:
			setError("Prefer attribute '%s' not found" % settings.prefer_attribute)
			return

	var cell_to_slot := {}
	var keep_indices := PackedInt32Array()

	for idx in range(in_data.size()):
		var pos = positions[idx]
		var key := Vector3i(
			int(round(pos.x / cell_size)),
			int(round(pos.y / cell_size)),
			int(round(pos.z / cell_size))
		)

		if not cell_to_slot.has(key):
			cell_to_slot[key] = keep_indices.size()
			keep_indices.append(idx)
			continue

		if prefer_stream != null and settings.prefer_value != "":
			var slot : int = cell_to_slot[key]
			var kept_idx : int = keep_indices[slot]
			var kept_is_preferred : bool = str(prefer_stream.container[kept_idx]) == settings.prefer_value
			var incoming_is_preferred : bool = str(prefer_stream.container[idx]) == settings.prefer_value
			if incoming_is_preferred and not kept_is_preferred:
				keep_indices[slot] = idx

	set_output( 0, in_data.filter( keep_indices ) )
