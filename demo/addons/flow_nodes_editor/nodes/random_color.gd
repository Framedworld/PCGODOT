@tool
extends FlowNodeBase

const RandomColorNodeSettings = preload("res://addons/flow_nodes_editor/nodes/random_color_settings.gd")

func _init():
	meta_node = {
		"title" : "Random Color",
		"settings" : RandomColorNodeSettings,
		"ins" : [{ "label" : "In" }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Generates random colors for each point.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if not in_data:
		setError("Input is invalid")
		return
	var out_data : FlowData.Data = in_data.duplicate()
	var in_size = in_data.size()
	
	var rng = RandomNumberGenerator.new()
	rng.seed = settings.random_seed
	
	var colors = PackedColorArray()
	colors.resize(in_size)
	
	var use_palette = settings.use_palette
	var palette = settings.palette
	var palette_size = palette.size()
	
	var h_min = settings.hue_min
	var h_max = settings.hue_max
	var s_min = settings.sat_min
	var s_max = settings.sat_max
	var v_min = settings.val_min
	var v_max = settings.val_max
	
	for i in range(in_size):
		if use_palette and palette_size > 0:
			var idx = rng.randi_range(0, palette_size - 1)
			colors[i] = palette[idx]
		else:
			var h = rng.randf_range(h_min, h_max)
			var s = rng.randf_range(s_min, s_max)
			var v = rng.randf_range(v_min, v_max)
			colors[i] = Color.from_hsv(h, s, v, 1.0)
		
	var err = out_data.registerStream(settings.out_name, colors)
	if err:
		setError(err)
		return
		
	set_output(0, out_data)
