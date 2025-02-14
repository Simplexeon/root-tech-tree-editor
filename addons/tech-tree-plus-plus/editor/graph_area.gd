@tool
extends TextureRect

# Properties

@export var TreeViewport : SubViewport;



# Processes

func _ready() -> void:
	
	if(TreeViewport):
		TreeViewport.size = size;
		texture = TreeViewport.get_texture();


func _on_resized() -> void:
	
	if(TreeViewport):
		TreeViewport.size = size;


func _input(event: InputEvent) -> void:
	
	if(TreeViewport):
		TreeViewport.push_input(event);
