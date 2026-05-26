@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Combine Points",
		"settings" : CombinePointsNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "For each input Point Data, outputs a new Point Data containing a single point that encompasses all points in its respective Point Data.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null or in_data.size() == 0:
		var empty = FlowData.Data.new()
		empty.addCommonStreams(0)
		set_output(0, empty)
		return
		
	var spos = in_data.getContainerChecked(FlowData.AttrPosition, FlowData.DataType.Vector)
	var ssizes = in_data.getContainerChecked(FlowData.AttrSize, FlowData.DataType.Vector)
	if spos == null:
		setError("Input points do not have a position stream")
		return
		
	var first = true
	var min_pos := Vector3.ZERO
	var max_pos := Vector3.ZERO
	
	for i in spos.size():
		var pos = spos[i]
		var size = ssizes[i] if ssizes else Vector3.ZERO
		var p_min = pos - size * 0.5
		var p_max = pos + size * 0.5
		if first:
			min_pos = p_min
			max_pos = p_max
			first = false
		else:
			min_pos = min_pos.min(p_min)
			max_pos = max_pos.max(p_max)
			
	var center = (min_pos + max_pos) * 0.5
	var combined_size = max_pos - min_pos
	
	var out_data = FlowData.Data.new()
	out_data.addCommonStreams(1)
	
	var out_pos = out_data.cloneStream(FlowData.AttrPosition)
	var out_rot = out_data.cloneStream(FlowData.AttrRotation)
	var out_size = out_data.cloneStream(FlowData.AttrSize)
	
	out_pos[0] = center
	out_rot[0] = Vector3.ZERO
	out_size[0] = combined_size
	
	out_data.registerStream(FlowData.AttrPosition, out_pos, FlowData.DataType.Vector)
	out_data.registerStream(FlowData.AttrRotation, out_rot, FlowData.DataType.Vector)
	out_data.registerStream(FlowData.AttrSize, out_size, FlowData.DataType.Vector)
	
	for stream_name in in_data.streams:
		if stream_name in [FlowData.AttrPosition, FlowData.AttrRotation, FlowData.AttrSize]:
			continue
		var stream = in_data.streams[stream_name]
		var new_container = FlowData.Data.newContainerOfType(stream.data_type)
		new_container.resize(1)
		if stream.container.size() > 0:
			new_container[0] = stream.container[0]
		out_data.registerStream(stream_name, new_container, stream.data_type)
		
	set_output(0, out_data)
