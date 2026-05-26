@tool
extends FlowNodeBase

const DifferenceNodeSettings = preload("res://addons/flow_nodes_editor/nodes/difference_settings.gd")

func _init():
	meta_node = {
		"title" : "Difference",
		"settings" : DifferenceNodeSettings,
		"ins" : [{ "label": "In A" }, { "label": "In B" }],
		"outs" : [{ "label" : "Out" }],
		"hide_inputs" : true,
		"tooltip" : "Performs set operations between two point sets based on position/size overlap.",
	}

func getTitle() -> String:
	var op_idx = clampi(settings.operation, 0, DifferenceNodeSettings.eOperation.keys().size() - 1)
	return "Difference (%s)" % DifferenceNodeSettings.eOperation.keys()[op_idx]

func _is_editor_missing_input_context(ctx : FlowData.EvaluationContext) -> bool:
	return ctx.owner == null and Engine.is_editor_hint()

func _emit_empty_output() -> void:
	set_output(0, FlowData.Data.new())

func _safe_sizes(data : FlowData.Data, expected_size : int, input_label : String) -> Dictionary:
	var in_sizes = data.getVector3Container(FlowData.AttrSize)
	var out_sizes := PackedVector3Array()

	if in_sizes.size() == expected_size:
		out_sizes = in_sizes.duplicate()
	elif in_sizes.size() == 1 and expected_size > 0:
		out_sizes.resize(expected_size)
		out_sizes.fill(in_sizes[0])
	elif in_sizes.size() == 0:
		out_sizes.resize(expected_size)
		out_sizes.fill(Vector3.ONE)
	else:
		return {
			"ok": false,
			"error": "Input %s has invalid %s size (%d, expected %d or 1)" % [input_label, FlowData.AttrSize, in_sizes.size(), expected_size],
			"sizes": PackedVector3Array()
		}

	for i in range(out_sizes.size()):
		var s = out_sizes[i]
		if not s.is_finite():
			s = Vector3.ONE
		s = Vector3(absf(s.x), absf(s.y), absf(s.z))
		# Keep extents strictly positive to avoid unstable overlap behavior.
		if is_zero_approx(s.x):
			s.x = 0.0001
		if is_zero_approx(s.y):
			s.y = 0.0001
		if is_zero_approx(s.z):
			s.z = 0.0001
		out_sizes[i] = s

	return { "ok": true, "error": "", "sizes": out_sizes }

func _sanitize_indices(indices, max_size : int) -> PackedInt32Array:
	var out := PackedInt32Array()
	if max_size <= 0:
		return out
	var seen := {}
	for idx in indices:
		var i = int(idx)
		if i < 0 or i >= max_size:
			continue
		if seen.has(i):
			continue
		seen[i] = true
		out.append(i)
	out.sort()
	return out

func _append_data(out_data : FlowData.Data, in_data : FlowData.Data, offset : int) -> int:
	var in_size = in_data.size()
	if in_size == 0:
		return offset

	for stream_name in in_data.streams:
		var stream : Dictionary = in_data.streams[stream_name]
		if not out_data.hasStream(stream_name):
			var container = FlowData.Data.newContainerOfType(stream.data_type)
			if container == null:
				setError("Failed to allocate stream '%s'" % stream_name)
				return -1
			container.resize(offset)
			var err = out_data.registerStream(stream_name, container, stream.data_type)
			if err:
				setError(err)
				return -1

		var out_stream = out_data.findStream(stream_name)
		if out_stream == null:
			setError("Failed to resolve output stream '%s'" % stream_name)
			return -1
		if out_stream.data_type != stream.data_type:
			setError("Conflicting stream type for '%s' between merged inputs (%s vs %s)" % [stream_name, out_stream.data_type, stream.data_type])
			return -1
		out_stream.container.append_array(stream.container)

	offset += in_size

	for stream_name in out_data.streams:
		var stream : Dictionary = out_data.streams[stream_name]
		if stream.container.size() < offset:
			stream.container.resize(offset)

	return offset

func _merge_data_sets(data_sets : Array) -> FlowData.Data:
	var out_data := FlowData.Data.new()
	var offset = 0
	for data in data_sets:
		if data == null:
			continue
		offset = _append_data(out_data, data, offset)
		if offset < 0:
			return null
	return out_data

func _resolve_union_overlap_source() -> int:
	var mode = settings.union_overlap_source
	if mode == DifferenceNodeSettings.eOverlapSource.LegacyKeepAFlag:
		return DifferenceNodeSettings.eOverlapSource.FromA if settings.keep_a_on_union_overlap else DifferenceNodeSettings.eOverlapSource.FromB
	return mode

func _build_overlap_output(mode : int, in_dataA : FlowData.Data, in_dataB : FlowData.Data, a_overlap : PackedInt32Array, b_overlap : PackedInt32Array) -> FlowData.Data:
	match mode:
		DifferenceNodeSettings.eOverlapSource.FromA:
			return in_dataA.filter(a_overlap)
		DifferenceNodeSettings.eOverlapSource.FromB:
			return in_dataB.filter(b_overlap)
		DifferenceNodeSettings.eOverlapSource.MergeAAndB:
			return _merge_data_sets([
				in_dataA.filter(a_overlap),
				in_dataB.filter(b_overlap),
			])
		_:
			return in_dataA.filter(a_overlap)

func execute(ctx : FlowData.EvaluationContext):
	var in_dataA : FlowData.Data = get_input(0)
	var in_dataB : FlowData.Data = get_input(1)

	if in_dataA == null:
		if _is_editor_missing_input_context(ctx):
			set_output(0, FlowData.Data.new())
			return
		setError("Input A not found")
		return
	if in_dataB == null:
		if _is_editor_missing_input_context(ctx):
			set_output(0, FlowData.Data.new())
			return
		setError("Input B not found")
		return

	var op_idx = clampi(settings.operation, 0, DifferenceNodeSettings.eOperation.keys().size() - 1)
	var op = op_idx

	if in_dataA.size() == 0 and in_dataB.size() == 0:
		_emit_empty_output()
		return
	if in_dataA.size() == 0:
		match op:
			DifferenceNodeSettings.eOperation.B_Minus_A, DifferenceNodeSettings.eOperation.Union, DifferenceNodeSettings.eOperation.SymmetricDifference:
				set_output(0, in_dataB.duplicate())
			_:
				_emit_empty_output()
		return
	if in_dataB.size() == 0:
		match op:
			DifferenceNodeSettings.eOperation.A_Minus_B, DifferenceNodeSettings.eOperation.Union, DifferenceNodeSettings.eOperation.SymmetricDifference:
				set_output(0, in_dataA.duplicate())
			_:
				_emit_empty_output()
		return

	var posA = in_dataA.getVector3Container(FlowData.AttrPosition)
	var posB = in_dataB.getVector3Container(FlowData.AttrPosition)
	if posA.size() != in_dataA.size() or posB.size() != in_dataB.size():
		setError("Inputs A/B must provide %s with one entry per point" % FlowData.AttrPosition)
		return
	for i in range(posA.size()):
		if not posA[i].is_finite():
			setError("Input A has non-finite position at index %d" % i)
			return
	for i in range(posB.size()):
		if not posB[i].is_finite():
			setError("Input B has non-finite position at index %d" % i)
			return

	var size_result_a = _safe_sizes(in_dataA, posA.size(), "A")
	if not size_result_a.ok:
		setError(size_result_a.error)
		return
	var size_result_b = _safe_sizes(in_dataB, posB.size(), "B")
	if not size_result_b.ok:
		setError(size_result_b.error)
		return
	var szA : PackedVector3Array = size_result_a.sizes
	var szB : PackedVector3Array = size_result_b.sizes

	var tA := GDRTree.new()
	var tB := GDRTree.new()
	tA.add(posA, szA)
	tB.add(posB, szB)

	var a_only = _sanitize_indices(tA.overlaps(posB, szB, false).idxs_overlapped, in_dataA.size())
	var a_overlap = _sanitize_indices(tA.overlaps(posB, szB, true).idxs_overlapped, in_dataA.size())
	var b_only = _sanitize_indices(tB.overlaps(posA, szA, false).idxs_overlapped, in_dataB.size())
	var b_overlap = _sanitize_indices(tB.overlaps(posA, szA, true).idxs_overlapped, in_dataB.size())

	match op:
		DifferenceNodeSettings.eOperation.A_Minus_B:
			set_output(0, in_dataA.filter(a_only))
		DifferenceNodeSettings.eOperation.B_Minus_A:
			set_output(0, in_dataB.filter(b_only))
		DifferenceNodeSettings.eOperation.Intersection:
			var out_intersection = _build_overlap_output(settings.intersection_overlap_source, in_dataA, in_dataB, a_overlap, b_overlap)
			if out_intersection == null:
				return
			set_output(0, out_intersection)
		DifferenceNodeSettings.eOperation.Union:
			var overlap_data = _build_overlap_output(_resolve_union_overlap_source(), in_dataA, in_dataB, a_overlap, b_overlap)
			if overlap_data == null:
				return
			var out_union = _merge_data_sets([
				in_dataA.filter(a_only),
				in_dataB.filter(b_only),
				overlap_data
			])
			if out_union == null:
				return
			set_output(0, out_union)
		DifferenceNodeSettings.eOperation.SymmetricDifference:
			var out_sym = _merge_data_sets([
				in_dataA.filter(a_only),
				in_dataB.filter(b_only)
			])
			if out_sym == null:
				return
			set_output(0, out_sym)
