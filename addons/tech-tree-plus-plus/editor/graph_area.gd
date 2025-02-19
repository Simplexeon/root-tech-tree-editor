@tool
extends SubViewportContainer

# Properties

@export var TreeViewport : SubViewport;



# Processes

func is_editor_hint() -> bool:
	return false;

func _input(event: InputEvent) -> void:
	
	if(event is InputEventMouse):
		# fix by ArdaE https://github.com/godotengine/godot/issues/17326#issuecomment-431186323
		var mouseEvent = event.duplicate();
		mouseEvent.position = get_global_transform_with_canvas().affine_inverse() * event.position;
		
		if(TreeViewport):
			TreeViewport.push_input(mouseEvent, false);
		return;
	
	if(TreeViewport):
		TreeViewport.push_input(event);

func _unhandled_input(event: InputEvent) -> void:
	
	if(event is InputEventMouse):
		# fix by ArdaE https://github.com/godotengine/godot/issues/17326#issuecomment-431186323
		var mouseEvent = event.duplicate();
		mouseEvent.position = get_global_transform_with_canvas().affine_inverse() * event.position;
		
		if(TreeViewport):
			TreeViewport.push_input(mouseEvent, false);
		return;
	
	if(TreeViewport):
		TreeViewport.push_input(event);