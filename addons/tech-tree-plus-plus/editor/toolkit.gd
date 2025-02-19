@tool
extends PanelContainer


# Properties


@export_subgroup("Elements")
@export var AddNodeButton : Button;
@export var EditorArea : Node2D;

@export_subgroup("Files")
@export var NodeEditorScene : PackedScene;


# Data

var next_node_id : int = 1;


# Processes

func _ready() -> void:
	
	# Setup UI
	
	if(AddNodeButton):
		AddNodeButton.pressed.connect(add_node);


# Functions

func add_node() -> void:
	if(NodeEditorScene.can_instantiate() and EditorArea):
		
		var node_editor : TechTreeNodeEditor = NodeEditorScene.instantiate();
		EditorArea.add_child(node_editor);
		node_editor.global_position = Vector2.ZERO;
		
		node_editor.setup(next_node_id);
		next_node_id += 1;
		