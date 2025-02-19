@tool
extends Button

# Signals

signal move(relative : Vector2);


var dragging : bool = false :
	set(value):
		dragging = value;
		
		if(dragging):
			mouse_default_cursor_shape = Control.CURSOR_DRAG;
		else:
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND;



# Processes

func _input(event: InputEvent) -> void:
	
	if(dragging and event is InputEventMouseMotion):
		move.emit(event.relative);



func _on_drag_tab_button_down() -> void:
	dragging = true;


func _on_drag_tab_button_up() -> void:
	dragging = false;
