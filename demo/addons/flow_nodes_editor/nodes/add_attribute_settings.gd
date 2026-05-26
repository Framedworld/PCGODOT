@tool
class_name AddAttributeNodeSettings
extends NodeSettings

@export_group("Add Attribute")

@export var name : String = "new_attr"
@export var data_type : FlowData.DataType = FlowData.DataType.Float:
	set(new_value):
		data_type = new_value
		notify_property_list_changed()
		
@export var cte_bool: bool = false
@export var cte_int : int = 0
@export var cte_float : float = 0.0
@export var cte_vector : Vector3 = Vector3.ZERO
@export var cte_color : Color = Color.WHITE
@export var cte_resource : Resource
@export var cte_string : String = ""

func _init():
	super._init()
	resource_name = "Add Attribute"

func exposeParam( name : String ):
	var name_lc = FlowData.DataType.keys()[ data_type ].to_lower()
	if name.begins_with( "cte_" ):
		return name == "cte_" + name_lc
	return true
