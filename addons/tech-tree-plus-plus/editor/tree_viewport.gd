extends SubViewport

# Signals

signal viewport_input(event : InputEvent);


# Processes

func _input(event: InputEvent) -> void:
	viewport_input.emit(event);
	
	print("Input here")
