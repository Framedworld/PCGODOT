@tool
extends FlowNodeBase

func _init():
	meta_node = {
		"title" : "Add Attribute",
		"settings" : AddAttributeNodeSettings,
		"ins" : [{ "label": "In" }], 
		"outs" : [{ "label" : "Out" }],
		"tooltip" : "Add a new constant stream to the input set\nIf the input is not given a single entry with the constant value is created.",
	}
	
func getTitle() -> String:
	return "%s - %s" % [ settings.name, FlowData.DataType.keys()[settings.data_type] ]

func exposedAsInputNode( prop ):
	if prop.name.begins_with( "cte_" ):
		var name_lc = FlowData.DataType.keys()[ settings.data_type ].to_lower()
		return prop.name == "cte_" + name_lc
	return false

func onPropChanged( prop_name : String ):
	super.onPropChanged( prop_name )
	if prop_name == "data_type":
		initFromScript()

func execute( ctx : FlowData.EvaluationContext ):
	var in_data : FlowData.Data = get_optional_input(0)
	var out_data : FlowData.Data
	var out_size := 1
	if in_data:
		out_data = in_data.duplicate()
		out_size = in_data.size()
	else:
		out_data = FlowData.Data.new()
	
	var new_val
	match settings.data_type:
		FlowData.DataType.Bool:
			new_val = 1 if getSettingValue( ctx, "cte_bool") else 0
		FlowData.DataType.Int:
			new_val = getSettingValue( ctx, "cte_int" )
		FlowData.DataType.Float:
			new_val = getSettingValue( ctx, "cte_float" )
		FlowData.DataType.Vector:
			new_val = getSettingValue( ctx, "cte_vector" )
		FlowData.DataType.Color:
			new_val = getSettingValue( ctx, "cte_color" )
		FlowData.DataType.String:
			new_val = getSettingValue( ctx, "cte_string" )
		FlowData.DataType.Resource:
			new_val = getSettingValue( ctx, "cte_resource" )

	var container = out_data.newContainerOfType( settings.data_type )
	container.resize( out_size )
	container.fill( new_val )

	out_data.registerStream( settings.name, container, settings.data_type )
	set_output( 0, out_data )
