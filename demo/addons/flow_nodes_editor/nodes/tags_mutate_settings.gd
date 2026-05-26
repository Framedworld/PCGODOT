@tool
extends NodeSettings

@export_group("Tags")

enum eOperation {
	Add,
	Remove,
	Replace,
}

@export var operation : eOperation = eOperation.Add
@export var tags_csv : String = ""
@export var case_sensitive : bool = false

func _init():
	super._init()
	resource_name = "Tags Mutate Settings"
