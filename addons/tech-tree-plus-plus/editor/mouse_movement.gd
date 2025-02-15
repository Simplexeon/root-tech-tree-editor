@tool
extends Control


# Signals

signal mouse_drag(relative_pos : Vector2);


# Data

var dragging : bool = false :
	set(value):
		dragging = value;
		
		if(dragging):
			DisplayServer.cursor_set_shape(DisplayServer.CursorShape.CURSOR_MOVE);


# Processes

func _unhandled_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		if(event.button_index == 1 and event.pressed):
			if(!dragging):
				dragging = true;
				pass;
		
		if(event.button_index == 1 and event.is_released()):
			if(dragging):
				dragging = false;
	
	if(event is InputEventMouseMotion and dragging):
		mouse_drag.emit(event.relative);