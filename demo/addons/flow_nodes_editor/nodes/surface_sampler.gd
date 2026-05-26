@tool
extends FlowNodeBase

const SurfaceSamplerNodeSettings = preload("res://addons/flow_nodes_editor/nodes/surface_sampler_settings.gd")

func _init():
	meta_node = {
		"title" : "Surface Sampler",
		"settings" : SurfaceSamplerNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Samples points randomly inside the bounds of the input points.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null or in_data.size() == 0:
		set_output(0, FlowData.Data.new())
		return
		
	var in_trs = in_data.getTransformsStream()
	if in_trs == null:
		setError("Input does not provide position, rotation, or scale streams")
		return
		
	var seed_val = getSettingValue(ctx, "random_seed", 12345)
	var num_pts = getSettingValue(ctx, "num_points", 40)
	var pt_size = getSettingValue(ctx, "point_size", Vector3.ONE)
	
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val
	
	var out_data := FlowData.Data.new()
	out_data.addCommonStreams(0)
	
	var spos := out_data.getVector3Container(FlowData.AttrPosition)
	var srot := out_data.getVector3Container(FlowData.AttrRotation)
	var ssize := out_data.getVector3Container(FlowData.AttrSize)
	
	var total_samples = in_trs.size() * num_pts
	spos.resize(total_samples)
	srot.resize(total_samples)
	ssize.resize(total_samples)
	
	var idx = 0
	for i in range(in_trs.size()):
		var center = in_trs.positions[i]
		var size = in_trs.sizes[i]
		var rotation = in_trs.eulers[i]
		var basis = FlowData.eulerToBasis(rotation)
		
		var half_size = size * 0.5
		
		for j in range(num_pts):
			# Generate local point in [-half_size, half_size]
			var lx = rng.randf_range(-half_size.x, half_size.x)
			var ly = rng.randf_range(-half_size.y, half_size.y)
			var lz = rng.randf_range(-half_size.z, half_size.z)
			var local_pt = Vector3(lx, ly, lz)
			
			# Transform to world space
			spos[idx] = center + (basis * local_pt)
			srot[idx] = rotation
			ssize[idx] = pt_size
			idx += 1
			
	set_output(0, out_data)
