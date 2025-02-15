@tool
extends SubViewportContainer

# Properties

@export var TreeViewport : SubViewport;



# Processes

func _input(event: InputEvent) -> void:
	
	if(TreeViewport):
		TreeViewport.push_input(event);
