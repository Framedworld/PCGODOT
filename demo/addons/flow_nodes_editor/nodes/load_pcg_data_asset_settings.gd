@tool
extends NodeSettings

@export_group("Load PCG Data Asset")

enum eAssetFormat {
	Auto,
	Json,
	Resource,
}

@export_file("*.json", "*.tres", "*.res") var asset_path : String = ""
@export var asset_format : eAssetFormat = eAssetFormat.Auto
@export var rows_property_name : String = "rows"
@export var streams_property_name : String = "streams"
@export var add_source_path : bool = true
@export var source_path_attribute : String = "source_path"

func _init():
	super._init()
	resource_name = "Load PCG Data Asset Settings"

func exposeParam(name : String) -> bool:
	if name == "source_path_attribute":
		return add_source_path
	return true
