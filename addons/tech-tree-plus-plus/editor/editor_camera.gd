@tool
extends Camera2D


# Properties

@export var Sensitivity : float = 1.0;



# Processes

func _on_mouse_drag(relative_pos : Vector2) -> void:
	global_position += relative_pos * Sensitivity * -1;
