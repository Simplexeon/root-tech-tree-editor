extends CharacterBody2D
class_name Player2D

# Parameters

@export_subgroup("Movement")
@export var Acceleration : Curve2D;
@export var AccelerationLength : float;
@export var Friction : Curve2D;
@export var StopLength : float;

@export_subgroup("Controls")
@export_range(0.05, 5.0) var MouseSensitivity : float;



# Components

@onready var Camera : Camera2D = $Camera;
@onready var Crosshair : Node2D = $Crosshair;



# Processes

func _ready() -> void:
	
	pass;


func _input(event: InputEvent) -> void:
	
	if(event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		Crosshair.global_position += event.relative;
	
	if(event is InputEventMouseButton):
		if(event.button_index == 1):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	
	if(event.is_action_pressed("ui_cancel")):
		if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
