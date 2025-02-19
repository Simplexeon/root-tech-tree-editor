@tool
extends Camera2D


# Properties

@export var Sensitivity : float = 1.0;
@export var ZoomStep : float;


# Data

var dragging : bool = false;

# Processes

func _unhandled_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		if((event.button_index == MOUSE_BUTTON_LEFT || 
			event.button_index == MOUSE_BUTTON_MIDDLE) and event.pressed):
			if(!dragging):
				dragging = true;
				pass;
		
		if((event.button_index == MOUSE_BUTTON_LEFT || 
			event.button_index == MOUSE_BUTTON_MIDDLE) and event.is_released()):
			if(dragging):
				dragging = false;
		
		if(event.button_index == MOUSE_BUTTON_WHEEL_UP):
			zoom += Vector2(ZoomStep, ZoomStep);
		
		if(event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			zoom -= Vector2(ZoomStep, ZoomStep);
		
	
	if(event is InputEventMouseMotion and dragging):
		global_position += event.relative * Sensitivity * -1;
		DisplayServer.cursor_set_shape(DisplayServer.CursorShape.CURSOR_MOVE);
