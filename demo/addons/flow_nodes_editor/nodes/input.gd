@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Input",
		"settings" : InputNodeSettings,
		"ins" : [],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Exposes an input of the Flow Graph Node into the Graph",
		"auto_register" : true,
		"hide_inputs" : true
	}

func getMeta() -> Dictionary:
	if node_template == "input":
		var outs = []
		var editor = getEditor()
		if editor and editor.current_resource:
			for param in editor.current_resource.in_params:
				if param:
					outs.append({
						"label": param.name,
						"data_type": param.data_type
					})
		meta_node.outs = outs
		meta_node.title = "Inputs"
	else:
		meta_node.title = "Input"
		if settings:
			meta_node.outs = [{ "label" : settings.name, "data_type" : settings.data_type }]
		else:
			meta_node.outs = [{ "label" : "Out", "data_type" : FlowData.DataType.Float }]
	return meta_node

func getTitle() -> String:
	if node_template == "input":
		return "Inputs"
	return settings.name

func refreshFromSettings():
	super.refreshFromSettings()
	if node_template == "input":
		pass
	else:
		var color := getColorForFlowDataType( settings.data_type )
		set_slot_color_right( 0, color )

func onPropChanged( prop_name : String ):
	super.onPropChanged( prop_name )
	if prop_name == "data_type" or prop_name == "name":
		refreshFromSettings()

func _ready():
	super._ready()
	if node_template == "input":
		var editor = getEditor()
		if editor and editor.current_resource:
			if not editor.current_resource.in_params_changed.is_connected(_on_in_params_changed):
				editor.current_resource.in_params_changed.connect(_on_in_params_changed)
			initFromScript()

func _exit_tree():
	super._exit_tree()
	if node_template == "input":
		var editor = getEditor()
		if editor and editor.current_resource:
			if editor.current_resource.in_params_changed.is_connected(_on_in_params_changed):
				editor.current_resource.in_params_changed.disconnect(_on_in_params_changed)

func _on_in_params_changed():
	initFromScript()

func initFromScript():
	super.initFromScript()
	if node_template == "input":
		var spacer = Control.new()
		spacer.custom_minimum_size.y = 4
		add_child(spacer)
		
		var btn = Button.new()
		btn.text = "+ Add Input Parameter"
		btn.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
		btn.add_theme_font_size_override("font_size", 10)
		if not btn.pressed.is_connected(_on_add_input_pressed):
			btn.pressed.connect(_on_add_input_pressed)
		add_child(btn)

func _on_add_input_pressed():
	var editor = getEditor()
	if editor and editor.current_resource:
		var index = 1
		var uname = "in_val"
		while editor._has_input_node_named(uname) or _has_in_param_named(editor.current_resource, uname):
			uname = "in_val_%d" % index
			index += 1
			
		var new_input = GraphInputParameter.new()
		new_input.name = uname
		new_input.data_type = FlowData.DataType.Float
		editor.current_resource.in_params.append( new_input )
		editor.current_resource.in_params_changed.emit()
		editor.queueSave()

func _has_in_param_named(res, uname: String) -> bool:
	for param in res.in_params:
		if param and param.name == uname:
			return true
	return false

func execute( ctx : FlowData.EvaluationContext ):
	if not ctx.graph:
		return
		
	if node_template == "input":
		for i in range(ctx.graph.in_params.size()):
			var param = ctx.graph.in_params[i]
			if not param:
				continue
			var output := FlowData.Data.new()
			var new_container = output.addStream( param.name, param.data_type )
			if new_container == null:
				continue
			var new_value = param.get_default_value()
			if ctx.owner and ctx.owner.args.has( param.name ):
				var ctx_value = ctx.owner.args[ param.name ]
				if FlowNodeBase.getFlowDataTypeFromGdScriptType( typeof( ctx_value ) ) == param.data_type:
					new_value = ctx.owner.args[ param.name ]
			var container = output.streams[ param.name ].container
			container.resize( 1 )
			container[0] = new_value
			set_output( i, output )
	else:
		if ctx.graph.in_params.size() == 0:
			setError( "Graph does not define any input")
			return
		
		var input = ctx.graph.findInParamByName( settings.name )
		if not input:
			setError( "%s is not a valid input name of the flow graph" % settings.name)
			return
		
		var output := FlowData.Data.new()
		var new_container = output.addStream( settings.name, input.data_type )
		if new_container == null:
			setError( "Invalid name %s or data_type %d (bool)" % [settings.name, input.data_type ])
			return
			
		var new_value = input.get_default_value()
		if ctx.owner and ctx.owner.args.has( input.name ):
			var ctx_value = ctx.owner.args[ input.name ]
			if FlowNodeBase.getFlowDataTypeFromGdScriptType( typeof( ctx_value ) ) == input.data_type:
				new_value = ctx.owner.args[ input.name ]

		var container =	output.streams[ settings.name ].container
		container.resize( 1 )
		container[0] = new_value
			
		set_output( 0, output )

