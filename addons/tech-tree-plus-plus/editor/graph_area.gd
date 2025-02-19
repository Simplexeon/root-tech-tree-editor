@tool
extends SubViewportContainer

# Properties

@export var TreeViewport : SubViewport;


# Data

var mouse_over : bool = false;


# Processes

func _ready() -> void:
	randomize();

func is_editor_hint() -> bool:
	return false;

func _input(event: InputEvent) -> void:
	
	if(!mouse_over or !visible):
		return;
	
	# Fix for event not processing properly sometimes
	var event_string : String = event.as_text();
	#print(event_string);
	
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
	
	if(!mouse_over or !visible):
		return;
	
	# Fix for event not processing properly sometimes
	var event_string : String = event.as_text();
	#print(event_string);
	
	if(event is InputEventMouse):
		# fix by ArdaE https://github.com/godotengine/godot/issues/17326#issuecomment-431186323
		var mouseEvent = event.duplicate();
		mouseEvent.position = get_global_transform_with_canvas().affine_inverse() * event.position;
		
		if(TreeViewport):
			TreeViewport.push_input(mouseEvent, false);
		return;
	
	if(TreeViewport):
		TreeViewport.push_input(event);


func _on_mouse_entered() -> void:
	mouse_over = true;


func _on_mouse_exited() -> void:
	mouse_over = false;
