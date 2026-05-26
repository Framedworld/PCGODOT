@tool
class_name FlowNodeBase
extends GraphNode

# This represent the base class for all nodes in the flow graph
# The actual nodes are implemented in the nodes subfolder

@export var settings: NodeSettings:
	set(new_value):
		if settings and settings.changed.is_connected(_on_settings_changed):
			settings.changed.disconnect(_on_settings_changed)
		settings = new_value
		if settings:
			settings.changed.connect(_on_settings_changed)

func _exit_tree():
	if settings and settings.changed.is_connected(_on_settings_changed):
		settings.changed.disconnect(_on_settings_changed)

func _on_settings_changed():
	dirty = true
	refreshFromSettings()
	var editor = getEditor()
	if editor:
		editor.queueRegen()

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# Common attributes ------------------------------
var num_connected_bulks : int = 0
var input_bulks : Array
var num_generated_bulks : int = 0
var generated_bulks : Array
var inputs = []

var args_ports_by_name = {}
var num_in_ports : int = 0
var num_out_ports : int = 0
var num_ports : int = 0			 # Max of (in,out)
var meta_node: Dictionary = {}

var node_template : String
var show_disconnected_inputs : bool = false

var dirty : bool = false

# Helper to create the UI
var connectors_row_prefab = preload( "res://addons/flow_nodes_editor/connectors_row.tscn" )
var connectors_options_prefab = preload( "res://addons/flow_nodes_editor/connectors_options.tscn" )

# Filled during runtime
var deps : Array[ Dictionary ]			# Array of graphEdit connections where I'm the target
var dependants : Array[ Dictionary ]	# Array of graphEdit connections where I'm the source
var eval_id : int = 0
var err : String

# Render
var draw_debug : NodeDrawDebug
var ui_scale = 1.0
var marker_radius : float = 9

var debug_row : int = -1

func _ready():
	ignore_invalid_connection_type = true
	checkDrawDebug()
	refreshInspectMark()
	refreshDebugMark()
	update_node_style()
	
func checkDrawDebug():
	if not is_instance_valid(draw_debug) or draw_debug.get_parent() != self:
		draw_debug = NodeDrawDebug.new()
		draw_debug.node = self
		add_child(draw_debug)
		# if the helper gets freed, clear our reference
		draw_debug.tree_exited.connect(func(): draw_debug = null)
		
func setupDrawDebug():
	checkDrawDebug()
	draw_debug.setupDraw()

func preExecute( ctx : FlowData.EvaluationContext ):
	eval_id = ctx.eval_id
	setError("")
	rng.seed = settings.random_seed
	num_generated_bulks = 0
	num_connected_bulks = 0
	input_bulks = []
	generated_bulks = []
	
	deps.map(func( conn : Dictionary ):
		# The number of bulkds in the pin 0 defines how many bulks we are going to generate
		if conn.to_port == 0:
			var node = ctx.gedit_nodes_by_name.get( conn.from_node )
			if node:
				num_connected_bulks += node.num_generated_bulks
	)
	if num_connected_bulks == 0:
		num_connected_bulks = 1

func redrawUI():
	queue_redraw()

func refreshDebugMark():
	redrawUI()

func refreshInspectMark():
	redrawUI()
	
func onPropChanged( prop_name : String ):
	dirty = true

func get_deterministic_color() -> Color:
	var h_hash = node_template.hash()
	var hue = float(h_hash % 360) / 360.0
	# We want premium colors, so let's set saturation to around 0.5 and value/brightness to 0.75
	return Color.from_hsv(hue, 0.5, 0.75)

func update_node_style():
	var hue = float(node_template.hash() % 360) / 360.0
	
	var is_colored = false
	var editor = getEditor()
	if editor and "color_nodes" in editor and editor.color_nodes:
		is_colored = true
		
	# Panel colors
	var panel_bg: Color
	var panel_selected_bg: Color
	var panel_border: Color
	var panel_selected_border: Color
	
	if is_colored:
		panel_bg = Color.from_hsv(hue, 0.25, 0.12, 0.9)
		panel_selected_bg = Color.from_hsv(hue, 0.25, 0.12, 0.9)
		panel_border = Color.from_hsv(hue, 0.25, 0.3, 0.9)
		panel_selected_border = Color("22d3ee") # Cyan #22d3ee accent border
	else:
		panel_bg = Color("1b1e28") # #1b1e28 node cards
		panel_selected_bg = Color("1b1e28")
		panel_border = Color(1.0, 1.0, 1.0, 0.07) # Translucent white border (Figma 1px rgba(255,255,255,0.07))
		panel_selected_border = Color("22d3ee") # Cyan #22d3ee accent border

	# Titlebar colors
	var title_bg: Color
	var title_selected_bg: Color
	
	if is_colored:
		title_bg = Color.from_hsv(hue, 0.25, 0.18, 1.0)
		title_selected_bg = Color.from_hsv(hue, 0.25, 0.22, 1.0)
	else:
		title_bg = Color("252836") # #252836 node headers
		title_selected_bg = Color("2e3244") # slightly lighter header when selected
		
	# StyleBox Panel
	var sb_panel = StyleBoxFlat.new()
	sb_panel.bg_color = panel_bg
	sb_panel.set_corner_radius_all(6) # Figma: 6px corner radius
	sb_panel.set_border_width_all(1)
	sb_panel.border_color = panel_border
	sb_panel.shadow_size = 16 # Figma: 16px shadow
	sb_panel.shadow_color = Color(0, 0, 0, 0.5)
	sb_panel.content_margin_left = 14 # Figma: paddingLeft: 14
	sb_panel.content_margin_right = 14 # Figma: paddingRight: 14
	sb_panel.content_margin_top = 0 # Figma: no gap between title and first port
	sb_panel.content_margin_bottom = 6 # Figma: 6px bottom padding
	add_theme_stylebox_override("panel", sb_panel)
	
	# StyleBox Panel Selected
	var sb_panel_selected = StyleBoxFlat.new()
	sb_panel_selected.bg_color = panel_selected_bg
	sb_panel_selected.set_corner_radius_all(6) # Figma: 6px corner radius
	sb_panel_selected.set_border_width_all(2)
	sb_panel_selected.border_color = panel_selected_border
	sb_panel_selected.shadow_size = 28 # Figma: 28px shadow
	sb_panel_selected.shadow_color = Color(0, 0, 0, 0.7)
	sb_panel_selected.content_margin_left = 14
	sb_panel_selected.content_margin_right = 14
	sb_panel_selected.content_margin_top = 0
	sb_panel_selected.content_margin_bottom = 6
	add_theme_stylebox_override("panel_selected", sb_panel_selected)
	
	# StyleBox Titlebar
	var sb_title = StyleBoxFlat.new()
	sb_title.bg_color = title_bg
	sb_title.corner_radius_top_left = 6 # Figma: 6px corner radius
	sb_title.corner_radius_top_right = 6
	sb_title.corner_radius_bottom_left = 0
	sb_title.corner_radius_bottom_right = 0
	sb_title.border_width_left = 0
	sb_title.border_width_top = 0
	sb_title.border_width_right = 0
	sb_title.border_width_bottom = 1
	sb_title.border_color = Color(1.0, 1.0, 1.0, 0.05) # Figma: borderBottom: "1px solid rgba(255,255,255,0.05)"
	sb_title.content_margin_left = 10 # Figma: paddingLeft: 10
	sb_title.content_margin_right = 10
	sb_title.content_margin_top = 9 # Figma: 34px total header height
	sb_title.content_margin_bottom = 9
	add_theme_stylebox_override("titlebar", sb_title)
	
	# StyleBox Titlebar Selected
	var sb_title_selected = StyleBoxFlat.new()
	sb_title_selected.bg_color = title_selected_bg
	sb_title_selected.corner_radius_top_left = 6 # Figma: 6px corner radius
	sb_title_selected.corner_radius_top_right = 6
	sb_title_selected.corner_radius_bottom_left = 0
	sb_title_selected.corner_radius_bottom_right = 0
	sb_title_selected.border_width_left = 0
	sb_title_selected.border_width_top = 0
	sb_title_selected.border_width_right = 0
	sb_title_selected.border_width_bottom = 1
	sb_title_selected.border_color = Color(1.0, 1.0, 1.0, 0.05)
	sb_title_selected.content_margin_left = 10
	sb_title_selected.content_margin_right = 10
	sb_title_selected.content_margin_top = 9
	sb_title_selected.content_margin_bottom = 9
	add_theme_stylebox_override("titlebar_selected", sb_title_selected)
	
	# Title text color overrides
	add_theme_color_override("title_color", Color("cdd0dc")) # Figma title color
	add_theme_color_override("title_selected_color", Color("ffffff"))
	
	var title_font = null
	if has_theme_font("bold", "EditorFonts"):
		title_font = get_theme_font("bold", "EditorFonts")
	elif has_theme_font("main", "EditorFonts"):
		title_font = get_theme_font("main", "EditorFonts")
	if title_font:
		add_theme_font_override("title_font", title_font)
	add_theme_font_size_override("title_font_size", 12)
	
	# Node width constraint (Figma NODE_WIDTH = 210)
	custom_minimum_size.x = 210
	
	# Port vertical separation (Figma spacing)
	add_theme_constant_override("separation", 4)
	
	self_modulate = Color.WHITE

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		if node_template == "subgraph" and settings and "graph" in settings and settings.graph:
			var editor = getEditor()
			if editor:
				editor.setResourceToEdit(settings.graph, null)

func refreshFromSettings():
	refreshDebugMark()
	refreshInspectMark()
	title = getTitle()
	modulate = Color( 0.7, 0.7, 0.7, 0.5 ) if settings.disabled else Color.WHITE
	
	update_node_style()
	
	if ( not settings.debug_enabled and draw_debug ) or settings.disabled:
		draw_debug.cleanup_multimesh_direct()
	
	if settings and "data_type" in settings and node_template != "add_attribute" and node_template != "attribute_random":
		var meta := getMeta()
		var outs = meta.get("outs", [])
		for idx in range(outs.size()):
			var out_data = outs[idx]
			if out_data:
				var data_type = out_data.get("data_type", FlowData.DataType.Invalid)
				if data_type == FlowData.DataType.Invalid:
					var color = getColorForFlowDataType(settings.data_type)
					if is_slot_enabled_right(idx):
						set_slot_color_right(idx, color)
						set_slot_type_right(idx, settings.data_type)
	
func setError( new_err : String ):
	if new_err:
		push_error( "Node.Err %s : %s" % [ name, new_err ])
		editor_state_changed.emit()
	err = new_err
	redrawUI()
		
func setActivity( amount : float ):
	if settings.disabled:
		return
	if not err:
		modulate = Color.WHITE + Color( amount, amount, amount, 0.0 )
	else:
		modulate = Color(1.0, 0.5, 0.5)
		
func _on_draw() -> void:
	
	if not settings:
		return

	if err:
		var sz = 16 * ui_scale
		draw_string( ThemeDB.fallback_font, Vector2(0,size.y + sz), err, HORIZONTAL_ALIGNMENT_LEFT, -1, sz )
		
	if settings.inspect_enabled:
		var clr : Color = Color.YELLOW / self_modulate
		draw_circle( Vector2(0,0), marker_radius * ui_scale, clr )
	if settings.debug_enabled:
		var clr : Color = Color.CYAN / self_modulate
		draw_circle( Vector2(size.x,0), marker_radius * ui_scale, clr )

	# Draw bottom decoration handle (Figma node style)
	var handle_w = 22.0 * ui_scale
	var handle_h = 3.0 * ui_scale
	var handle_x = (size.x - handle_w) / 2.0
	var handle_y = size.y - handle_h
	var handle_sb = StyleBoxFlat.new()
	handle_sb.bg_color = Color(1.0, 1.0, 1.0, 0.07)
	handle_sb.corner_radius_top_left = 2
	handle_sb.corner_radius_top_right = 2
	draw_style_box(handle_sb, Rect2(handle_x, handle_y, handle_w, handle_h))

func getMeta() -> Dictionary:
	return meta_node
	
func getTitle() -> String:
	return settings.title

func shuffleArray(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var temp = arr[i]
		arr[i] = arr[j]
		arr[j] = temp

static func editorDisplayName(property_name: String) -> String:
	var parts = property_name.split("_")
	for i in parts.size():
		parts[i] = parts[i].capitalize()
	return " ".join(parts)

static func getColorForFlowDataType( data_type : FlowData.DataType ) -> Color:
	match( data_type ):
		FlowData.DataType.Bool:
			return Color("ef4444")
		FlowData.DataType.Int:
			return Color("c8c8c8")
		FlowData.DataType.Float:
			return Color("c8c8c8")
		FlowData.DataType.Vector:
			return Color("a855f7")
		FlowData.DataType.Color:
			return Color("eab308")
		FlowData.DataType.String:
			return Color("3b82f6")
		FlowData.DataType.Resource:
			return Color("22c55e")
		FlowData.DataType.NodeMesh:
			return Color("22c55e")
		FlowData.DataType.NodePath:
			return Color("14b8a6")
	return Color("22d3ee") # Default cyan flow color

static func getGdScriptTypeForFlowDataType( data_type : FlowData.DataType ) -> int:
	match( data_type ):
		FlowData.DataType.Bool:
			return TYPE_BOOL
		FlowData.DataType.Int:
			return TYPE_INT
		FlowData.DataType.Float:
			return TYPE_FLOAT
		FlowData.DataType.String:
			return TYPE_STRING
		FlowData.DataType.Vector:
			return TYPE_VECTOR3
		FlowData.DataType.Color:
			return TYPE_COLOR
	return TYPE_NIL
	
static func getFlowDataTypeFromGdScriptType( gd_type : int  ) -> FlowData.DataType:
	match( gd_type ):
		TYPE_BOOL:
			return FlowData.DataType.Bool
		TYPE_INT:
			return FlowData.DataType.Int
		TYPE_FLOAT: 
			return FlowData.DataType.Float
		TYPE_STRING:
			return FlowData.DataType.String 
		TYPE_VECTOR3:
			return FlowData.DataType.Vector
		TYPE_COLOR:
			return FlowData.DataType.Color
	return FlowData.DataType.Invalid

static func getFlowDataTypeFromObject( obj  ) -> FlowData.DataType:
	var data_type = getFlowDataTypeFromGdScriptType( typeof(obj) ) 
	if data_type != FlowData.DataType.Invalid:
		return data_type
	if obj is Resource:
		return FlowData.DataType.Resource
	return data_type

func exposedAsInputNode( prop ):
	if prop.name == "graph":
		return false
	return true

func getExposedParams():
	var meta := getMeta()
	if meta.get( "hide_inputs", false ):
		return []
	var trace = meta.get( "trace", false )
	var my_title : String = meta.title
	var props = settings.get_property_list()
	var inside_my_vars := false
	var params = []
	for prop in props:
		if trace:
			print( "Input.", prop.name)
		if prop.name == "node_settings.gd":
			break
		if prop.name == "HiddenFromThisPoint":
			break
		if prop.name == my_title:
			inside_my_vars = true
		if !(prop.usage & PROPERTY_USAGE_STORAGE) || !(prop.usage & PROPERTY_USAGE_EDITOR):
			continue
		if !inside_my_vars:
			continue
			
		var data = {
			"name" : prop.name,
			"label" : editorDisplayName( prop.name ),
			"type" : prop.type,
			"data_type" : getFlowDataTypeFromGdScriptType( prop.type ),
			"is_parameter" : true,
			"port" : -1,
		}
		
		if not exposedAsInputNode( data ):
			continue
		
		params.append( data )
	return params

func getEditor():
	var gedit = get_parent_control() as GraphEdit
	var flow_editor = gedit.get_parent_control().get_parent_control().get_parent_control() as Control if gedit else null
	return flow_editor

func initFromScript():
	var meta := getMeta()
	var trace = meta.get( "trace", false )
	
	var ins = meta.get( "ins", [] )
	var outs = meta.get( "outs", [] )
	var num_ins = ins.size()
	var num_outs = outs.size()
	
	var exposed_params = getExposedParams()
	var has_exposed_params = exposed_params.size() > 0
	
	# Access to my parent container editor
	# We need to remember which nodes were connected as we might be expanded/contracting the list and want to 
	# maintain the same connected entries
	var flow_editor = getEditor()
	var connected_inputs_by_name = {}
	if flow_editor:
		for arg_name in args_ports_by_name:
			var arg_port = args_ports_by_name[ arg_name ].port
			var curr_connections = flow_editor.get_connected_sources( name, arg_port )
			#print( "Checking if %s is connected at port %d -> %d conns" % [ arg_name, arg_port, curr_connections.size() ] )
			if not curr_connections.is_empty():
				connected_inputs_by_name[ arg_name ] = { "port" : arg_port, "conns" : curr_connections.duplicate() }
				for old_conn in curr_connections:
					var from_node = old_conn[0]
					var from_port = old_conn[1]
					flow_editor.disconnect_nodes( from_node, from_port, name, arg_port )
		
		if not show_disconnected_inputs:
			exposed_params = exposed_params.filter( func( data ):
				return args_ports_by_name.has( data.name ) and args_ports_by_name[ data.name ].connected
			)
	else:
		# When we just instantiate the node
		exposed_params = []
		
	if trace:
		print( "flow_editor: %s" % flow_editor)
		print( "show_disconnected_inputs: %s" % show_disconnected_inputs)
		print( "all_exposed_params: %s" % exposed_params.size())
		print( "exposed_params: %s" % exposed_params.size())
		print( "args_ports_by_name: %s" % args_ports_by_name)
		
	# Total inputs are flow in streams + exposed parameters of the node
	var num_inputs = num_ins + exposed_params.size()
	num_ports = max( num_inputs, num_outs )
	num_in_ports = num_inputs
	num_out_ports = num_outs
	
	# Delete current children
	clear_all_slots()
	for child in get_children():
		if child == draw_debug:
			continue
		child.queue_free()
		remove_child( child )
	
	args_ports_by_name = {}
	for idx in range( 0, num_ports ):
		var ctrl = connectors_row_prefab.instantiate() as FlowConnectorRow
		add_child( ctrl )
		# Figma: PORT_ROW = 26px height
		ctrl.custom_minimum_size.y = 26
		
		var lbl_in = ctrl.getInLabel()
		var lbl_out = ctrl.getOutLabel()
		
		# Figma label typography & color overrides
		lbl_in.add_theme_color_override("font_color", Color("8b90a8"))
		lbl_in.add_theme_font_size_override("font_size", 11) # Figma: 11px font size
		lbl_in.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		lbl_out.add_theme_color_override("font_color", Color("8b90a8"))
		lbl_out.add_theme_font_size_override("font_size", 11) # Figma: 11px font size
		lbl_out.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		# Try to use monospaced editor source font
		var mono_font = null
		if lbl_in.has_theme_font("source", "EditorFonts"):
			mono_font = lbl_in.get_theme_font("source", "EditorFonts")
		elif lbl_in.has_theme_font("doc_source", "EditorFonts"):
			mono_font = lbl_in.get_theme_font("doc_source", "EditorFonts")
		if mono_font:
			lbl_in.add_theme_font_override("font", mono_font)
			lbl_out.add_theme_font_override("font", mono_font)
		
		# Is there an input active
		if idx < num_inputs:
			var in_data
			
			# Decide if it's a flow input, or just a param input
			if idx < num_ins:
				in_data = ins[idx]
			else:
				in_data = exposed_params[ idx - num_ins ]
			lbl_in.text = in_data.label
			
			var in_name = in_data.get( "name", in_data.label )
			
			set_slot_enabled_left( idx, true )
			
			# Change color
			var data_type = in_data.get( "data_type", FlowData.DataType.Invalid )
			if data_type == FlowData.DataType.Invalid and in_data.has( "type"):
				data_type = getFlowDataTypeFromGdScriptType( in_data.type )
			if data_type != FlowData.DataType.Invalid:
				var color = getColorForFlowDataType( data_type )	
				set_slot_color_left( idx, color )
				set_slot_type_left( idx, data_type )
				
			in_data.port = idx
			ctrl.setData( in_data )
			
			args_ports_by_name[ in_name ] = { "port" : idx, "connected" : connected_inputs_by_name.has( in_name ) }
			if trace:
				print( "%s : Assigning slot %d for input %s" % [ name, idx, in_name ])
		else:
			lbl_in.text = ""
			
		if idx < num_outs:
			var out_data = outs[idx]
			if out_data:
				lbl_out.text = out_data.label
				set_slot_enabled_right( idx, true )
					
				# Change color
				var data_type = out_data.get( "data_type", FlowData.DataType.Invalid )
				if data_type == FlowData.DataType.Invalid and out_data.has( "type"):
					data_type = getFlowDataTypeFromGdScriptType( out_data.type )
				if data_type == FlowData.DataType.Invalid and settings and "data_type" in settings and node_template != "add_attribute" and node_template != "attribute_random":
					data_type = settings.data_type
				if data_type != FlowData.DataType.Invalid:
					var color = getColorForFlowDataType( data_type )	
					set_slot_color_right( idx, color )
					set_slot_type_right( idx, data_type )					
					
		else:
			lbl_out.text = ""
	
	# Add a button to show/hide all props and maybe more options in the future
	if has_exposed_params:
		var ctrl = connectors_options_prefab.instantiate() as FlowConnectorOptions
		ctrl.setShowDisconnectedInputs( show_disconnected_inputs )
		ctrl.expand_toggled.connect( nodeOptionsChanged )
		add_child( ctrl )

	# Force a readjust of the node in the flow editor
	size = get_combined_minimum_size()
	
	if trace:
		for arg_name in args_ports_by_name.keys():
			print( "  %s : %s" % [ arg_name, args_ports_by_name[ arg_name ] ] )
	
	if flow_editor:
		# Reconnect nodes
		for arg_name in connected_inputs_by_name.keys():
			var old_data = connected_inputs_by_name[ arg_name ]
			var old_port = old_data.port
			var new_port = args_ports_by_name[ arg_name ].port
			for old_conn in old_data.conns:
				var from_node = old_conn[0]
				var from_port = old_conn[1]
				flow_editor.connect_nodes( from_node, from_port, name, new_port )
			flow_editor.queueSave()
		flow_editor.refreshSignalsInputArgs( self )
	
func refreshConnectionFlags( ):	
	var editor = getEditor()
	if editor:
		for arg_name in args_ports_by_name:
			args_ports_by_name[ arg_name ].connected = editor.is_node_port_connected( name, args_ports_by_name[ arg_name ].port )
		
func nodeOptionsChanged( expanded : bool ):
	show_disconnected_inputs = not show_disconnected_inputs
	refreshConnectionFlags( )
	initFromScript()
	setupDrawDebug()
	
# This returns the current value of the input configuration taking into account potencial connections and overrides of the inputs
func getSettingValue( ctx : FlowData.EvaluationContext, in_name : String, default_value = null):
	var meta = getMeta()
	var trace = meta.get( "trace", false )
	
	var value = settings.get( in_name )
	if value == null:
		value = default_value
	if trace:
		print( "Searching the current value of input %s in %d inputs at node %s. ByName:%s vs %s.   Meta:%s" % [ in_name, inputs.size(), name, args_ports_by_name, inputs, meta ] )
	if args_ports_by_name.has( in_name ):
		var port = args_ports_by_name[ in_name ].port
		if port >= 0 and port < inputs.size():
			var input = inputs[ port ] as FlowData.Data
			if input:
				var in_streams = input.streams
				if trace:
					print( "Got the input for %s : %s" % [ in_name, in_streams.keys() ] )
				if in_streams and in_streams.size() == 1:
					var stream = in_streams.values()[0]
					var in_size = in_streams.size()
					if in_size == 0:
						setError( "Input %s has no data" % in_name)
					elif in_size > 1:
						setError( "Input %s has too many data (%d)" % [ in_name, in_size ])
					else:
						var new_value = stream.container[0]
						if trace:
							print( "  -> Using %s = %s" % [ in_name, new_value ])
						if typeof( new_value ) != typeof( value ):
							push_warning( "  Type of %s (%d) does not match the expected type (%d)" % [ in_name, typeof(new_value), typeof(value) ])
							
						return new_value
	return value

func newStream( size : int, new_name : String, init_value, data_type : FlowData.DataType ):
	var new_container = FlowData.Data.newContainerOfType( data_type )
	new_container.resize( size )
	if typeof(init_value) == TYPE_CALLABLE:
		var fn : Callable = init_value
		match data_type:
			FlowData.DataType.Bool:
				var typed_container : PackedByteArray = new_container
				for idx in size:
					typed_container[idx] = fn.call(idx)
			FlowData.DataType.Int:
				var typed_container : PackedInt32Array = new_container
				for idx in size:
					typed_container[idx] = fn.call(idx)
			FlowData.DataType.Float:
				var typed_container : PackedFloat32Array = new_container
				for idx in size:
					typed_container[idx] = fn.call(idx)
			FlowData.DataType.Vector:
				var typed_container : PackedVector3Array = new_container
				for idx in size:
					typed_container[idx] = fn.call(idx)
			FlowData.DataType.Color:
				var typed_container : PackedColorArray = new_container
				for idx in size:
					typed_container[idx] = fn.call(idx)
			FlowData.DataType.String:
				var typed_container : PackedStringArray = new_container
				for idx in size:
					typed_container[idx] = fn.call(idx)
			FlowData.DataType.Resource:
				var typed_container : Array = new_container
				for idx in size:
					typed_container[idx] = fn.call(idx)
			_:
				push_error( "newStream(%d) type not supported" % [ data_type ])
				return null
	else:
		new_container.fill( init_value )
	return { 
		"data_type" : data_type,
		"container" : new_container,
		"name" : new_name
	}
	
func newFloatStream( size : int, new_name : String, init_value ):
	return newStream( size, new_name, init_value, FlowData.DataType.Float )

func getSceneRootNode3d( current : Node3D ) -> Node3D:
	while current and current.get_parent_node_3d():
		current = current.get_parent_node_3d()
	return current

func findNodesMatchingFilters( ctx : FlowData.EvaluationContext, filter_by_class_name : String ) -> Array[ Node3D ]:

	var group_name = getSettingValue( ctx, "group_name" )
	
	var all_nodes : Array[Node] = []
	#var scene_root = ctx.owner.get_tree().root
	if group_name:
		all_nodes = ctx.owner.get_tree().get_nodes_in_group( group_name )
	elif ctx.owner:
		var root = getSceneRootNode3d( ctx.owner )
		all_nodes = root.get_children()
	
	if settings.trace:
		print( "all_nodes", all_nodes )
	
	# Filter to only include nodes in the current scene
	var scene_nodes : Array[ Node3D ] = []
	for node in all_nodes:
		var node3d := node as Node3D
		if node3d:
			if filter_by_class_name and not node3d.is_class( filter_by_class_name ):
				if settings.trace:
					print( "%s.%s discarted by class_name %s" % [ node3d.name, node3d.get_class(), filter_by_class_name ])
				continue
			scene_nodes.append(node3d)
	return scene_nodes

# --------------------------------------------------------------------------
func set_output( port_idx : int, data : FlowData.Data ):
	if port_idx == 0:
		num_generated_bulks += 1
		generated_bulks.append( [] )
	var bulk : Array = generated_bulks[ num_generated_bulks - 1]
	if port_idx >= bulk.size():
		bulk.resize( port_idx + 1 )
	#print( "Saving bulk %d, port %d with %s (%d entries)" % [ num_generated_bulks - 1, port_idx, data.streams.keys(), data.size() ] )
	bulk[ port_idx ] = data
	
func get_input( idx : int ):
	if idx >= inputs.size():
		push_error( "Input.%d does not exists in node %s" % [ idx, name ])
		return []
	return inputs[ idx ]

func get_optional_input( idx : int ):
	if idx >= inputs.size():
		return null
	return inputs[ idx ]

func get_bulk_input( bulk_idx : int, port_idx : int ):
	if bulk_idx < input_bulks.size() && port_idx < getMeta().ins.size():
		return input_bulks[ bulk_idx ][ port_idx ]
	return null
	
func get_bulk_output( bulk_idx : int, port_idx : int ):
	if bulk_idx >= generated_bulks.size():
		push_error( "Node %s has not generated bulk %d" % [ name, bulk_idx ])
		return FlowData.Data.new()
	if port_idx >= generated_bulks[ bulk_idx ].size():
		push_error( "Node %s bulk %d has not generated output %d" % [ name, bulk_idx, port_idx ])
		return FlowData.Data.new()
	return generated_bulks[ bulk_idx ][ port_idx ]

func execute( ctx ):
	pass

func _getInputForBulkInContext( ctx : FlowData.EvaluationContext, bulk_idx : int, port_idx : int ):
	var bulk_counter = 0
	#print( "_getInputForBulkInContext( %d, %d )" % [ bulk_idx, port_idx ] )
	for conn in deps:
		var to_port = conn.to_port
		if to_port != port_idx:
			continue
		var src_node = ctx.gedit_nodes_by_name.get( conn.from_node )
		if not src_node:
			continue
		#print( "  Found.src_node is %s. Has generated %d bulks. So far we have explored %d bulks" % [ src_node, src_node.generated_bulks.size(), bulk_counter ] )
		var from_port = conn.from_port
		for input_bulk_idx in range( src_node.generated_bulks.size() ):
			if bulk_counter == bulk_idx:
				return src_node.get_bulk_output( input_bulk_idx, from_port )
			bulk_counter += 1
	return null

func readAllInputsForBulk( ctx : FlowData.EvaluationContext, bulk_idx : int ):
	inputs = []
	var num_inputs : int = getMeta().ins.size()
	for port_idx in range( num_inputs ):
		inputs.append( _getInputForBulkInContext( ctx, bulk_idx, port_idx ))
	
	# Read the options inputs, assuming they only generate a single bulk
	var option_idx = num_inputs
	for conn in deps:
		if conn.to_port >= num_inputs:
			#print( "Checking conn %s" % conn )
			var config_input = _getInputForBulkInContext( ctx, 0, conn.to_port )
			#print( "  -> %s" % config_input.streams  )
			if conn.to_port >= inputs.size():
				inputs.resize( conn.to_port + 1 )
			inputs[ conn.to_port ] = config_input
			option_idx += 1
	input_bulks.append( inputs )

# Defines the behaviour of the node in it's disabled status
# The default behaviour is to pass all inputs as outputs	
func executedDisabled( ctx : FlowData.EvaluationContext ):
	for bulk_index in range( num_connected_bulks ):
		readAllInputsForBulk( ctx, bulk_index )
		if inputs.size() > 0:
			set_output( 0, inputs[0] )

func run( ctx : FlowData.EvaluationContext ):
	for bulk_index in range( num_connected_bulks ):
		readAllInputsForBulk( ctx, bulk_index )
		if settings.trace:
			print( "%s Inputs for bulk %d/%d are %s" % [ name, bulk_index, num_connected_bulks, inputs ])
		execute( ctx )
