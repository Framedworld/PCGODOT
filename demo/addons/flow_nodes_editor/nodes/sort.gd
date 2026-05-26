@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Sort",
		"settings" : SortNodeSettings,
		"ins" : [{"label": "In" }], 
		"outs" : [{ "label" : "Out" }],
		"hide_inputs" : true,
		"tooltip" : "Reorders the points based on the values of stream",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	var sA = in_data.findStream( settings.sort_by )
	if sA == null:
		setError( "Input %s not found" % [settings.sort_by])
		return
	var indices : PackedInt32Array
	if sA.data_type == FlowData.DataType.Float:
		indices = GDStreamUtils.get_sorted_indices_f32( sA.container )
	elif sA.data_type == FlowData.DataType.Int:
		indices = GDStreamUtils.get_sorted_indices_i32( sA.container )
	elif sA.data_type == FlowData.DataType.String:
		indices = GDStreamUtils.get_sorted_indices_string( sA.container )
	else:
		setError( "Unsupported sort data type: %d" % sA.data_type )
		return

	if settings.sort_descending:
		indices.reverse()
		
	var out_data = in_data.filter( indices )
	set_output( 0, out_data )
