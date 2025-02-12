@tool
extends Camera2D


# Properties

@export var Sensitivity : float = 1.0;


# Data

var dragging : bool = false;



# Processes

func _input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		if(event.button_index == 1 and event.pressed):
			if(!dragging):
				#dragging = true;
				pass;
		
		if(event.button_index == 1 and event.is_released()):
			if(dragging):
				dragging = false;
	
	if(event is InputEventMouseMotion and dragging):
		global_position += event.relative * Sensitivity * -1;
