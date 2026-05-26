@tool
extends NodeSettings

@export_group("Load Data Table")

enum eDelimiter {
	Comma,
	Tab,
	Semicolon,
	Pipe,
}

@export_file("*.csv", "*.tsv", "*.txt") var table_path : String = ""
@export var delimiter : eDelimiter = eDelimiter.Comma
@export var first_row_is_header : bool = true
@export var trim_values : bool = true
@export var infer_column_types : bool = true
@export var add_row_index : bool = true
@export var row_index_attribute : String = "row_index"
@export var add_source_path : bool = false
@export var source_path_attribute : String = "source_path"

func _init():
	super._init()
	resource_name = "Load Data Table Settings"

func exposeParam(name : String) -> bool:
	if name == "row_index_attribute":
		return add_row_index
	if name == "source_path_attribute":
		return add_source_path
	return true
