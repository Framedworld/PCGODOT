@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Duplicate Point",
		"settings" : DuplicatePointNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "For each point, duplicate the point and move it along an axis defined by the Direction/Offset, and apply a transform on the new point.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input 'In' is not connected")
		return
		
	var out_data : FlowData.Data = FlowData.Data.new()
	var in_size = in_data.size()
	var iters = clampi(settings.iterations, 1, 100)
	var new_size = in_size * (iters + 1)
	
	for name in in_data.streams:
		var stream = in_data.streams[name]
		var new_container = FlowData.Data.newContainerOfType(stream.data_type)
		new_container.resize(new_size)
		out_data.registerStream(name, new_container, stream.data_type)
		
	for name in in_data.streams:
		var stream = in_data.streams[name]
		var out_container = out_data.streams[name].container
		for i in in_size:
			out_container[i] = stream.container[i]
			
	var spos = out_data.streams[FlowData.AttrPosition].container
	var srot = out_data.streams[FlowData.AttrRotation].container
	var ssizes = out_data.streams[FlowData.AttrSize].container
	
	var offset_vec = settings.offset
	var relative = settings.offset_relative
	
	for iter in range(1, iters + 1):
		var dst_start = in_size * iter
		
		for name in in_data.streams:
			if name in [FlowData.AttrPosition, FlowData.AttrRotation, FlowData.AttrSize]:
				continue
			var stream = in_data.streams[name]
			var out_container = out_data.streams[name].container
			for i in in_size:
				out_container[dst_start + i] = stream.container[i]
				
		for i in in_size:
			var dst_idx = dst_start + i
			var pos = spos[i]
			var rot = srot[i]
			var size = ssizes[i]
			
			var final_pos = pos
			if relative:
				var basis = FlowData.eulerToBasis(rot)
				final_pos += basis * (offset_vec * iter)
			else:
				final_pos += offset_vec * iter
				
			spos[dst_idx] = final_pos
			srot[dst_idx] = rot
			ssizes[dst_idx] = size
			
	set_output(0, out_data)
