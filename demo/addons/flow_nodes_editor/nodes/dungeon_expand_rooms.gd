@tool
extends FlowNodeBase

const DungeonExpandRoomsSettings = preload("res://addons/flow_nodes_editor/nodes/dungeon_expand_rooms_settings.gd")

func _init():
	meta_node = {
		"title" : "Dungeon Expand Rooms",
		"settings" : DungeonExpandRoomsSettings,
		"ins" : [{ "label" : "In" }],
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Expands single room center points into grid floor tiles covering their width and height.",
	}

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_input(0)
	if in_data == null:
		setError("Input 'In' is not connected")
		return
	if in_data.size() == 0:
		set_output(0, FlowData.Data.new())
		return
		
	var cell_size : float = getSettingValue(ctx, "cell_size", 2.0)
	
	var in_size = in_data.size()
	var in_pos = in_data.getVector3Container(FlowData.AttrPosition)
	
	var s_width = in_data.findStream("RoomWidth")
	var s_height = in_data.findStream("RoomHeight")
	var s_room_id = in_data.findStream("RoomID")
	
	if s_width == null or s_height == null or s_room_id == null:
		setError("Input points must have RoomWidth, RoomHeight, and RoomID attributes")
		return
		
	var out_positions = PackedVector3Array()
	var out_room_ids = PackedInt32Array()
	var out_cell_types = PackedStringArray()
	
	for i in range(in_size):
		var center = in_pos[i]
		var rw = int(s_width.container[i])
		var rh = int(s_height.container[i])
		var room_id = int(s_room_id.container[i])
		
		# Find the bottom-left coordinate of the room
		var rx = round(center.x / cell_size) - int(rw / 2.0)
		var ry = round(center.z / cell_size) - int(rh / 2.0)
		
		for dy in range(rh):
			for dx in range(rw):
				var pos = Vector3((rx + dx) * cell_size, 0, (ry + dy) * cell_size)
				out_positions.append(pos)
				out_room_ids.append(room_id)
				out_cell_types.append("Room")
				
	var n_points = out_positions.size()
	var output := FlowData.Data.new()
	output.addCommonStreams(n_points)
	
	var spos = output.getVector3Container(FlowData.AttrPosition)
	var srot = output.getVector3Container(FlowData.AttrRotation)
	var ssize = output.getVector3Container(FlowData.AttrSize)
	
	for idx in range(n_points):
		spos[idx] = out_positions[idx]
		srot[idx] = Vector3.ZERO
		ssize[idx] = Vector3(cell_size, 1.0, cell_size)
		
	output.registerStream("RoomID", out_room_ids, FlowData.DataType.Int)
	output.registerStream("room_id", out_room_ids, FlowData.DataType.Int)
	output.registerStream("CellType", out_cell_types, FlowData.DataType.String)
	
	var out_types = PackedFloat32Array()
	out_types.resize(n_points)
	out_types.fill(0.0)
	output.registerStream("type", out_types, FlowData.DataType.Float)
	
	set_output(0, output)
