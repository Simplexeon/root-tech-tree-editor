@tool
extends TextureRect
class_name TechTreeEditorConnector


# Properties

@export var Type : ConnectorType;


enum ConnectorType {
	Parent,
	Child
}


# Processes

func setup(type : ConnectorType) -> void:
	Type = type;