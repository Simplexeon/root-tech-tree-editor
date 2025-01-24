extends CharacterBody2D
class_name Player2D

# Parameters

@export_subgroup("Movement")
@export var Acceleration : float;
@export var AccelerationRamp : Curve;
@export var TargetSpeed : float;
@export var Friction : Curve;
@export var MaxFriction : float;
@export_range(-1.0, 1.0) var TurningPoint : float;

@export_subgroup("Controls")
@export_range(0.05, 5.0) var MouseSensitivity : float;
@export var MouseRange : float;


@export_subgroup("Camera")
@export var MaxViewDistance : float;
@export_exp_easing("attenuation") var CameraSmoothing : float;


# Components

@onready var Camera : Camera2D = $Camera;
@onready var Crosshair : Node2D = $Crosshair;



# Processes

func _ready() -> void:
	
	AccelerationRamp.bake();
	Friction.bake();


func _input(event: InputEvent) -> void:
	
	if(event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		Crosshair.global_position += event.relative;
	
	if(event is InputEventMouseButton):
		if(event.button_index == 1):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	
	if(event.is_action_pressed("ui_cancel")):
		if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;


func _process(delta: float) -> void:
	
	Camera.global_position = Camera.global_position.lerp(get_camera_pos(Crosshair.global_position), CameraSmoothing * delta);
	look_at(Camera.global_position);
	


func _physics_process(delta: float) -> void:
	
	# Limit Crosshair
	var mouse_vect = Crosshair.global_position - global_position;
	Crosshair.global_position = global_position + (mouse_vect.normalized() * min(mouse_vect.length(), MouseRange));
	
	process_movement(delta);


# Functions

func get_camera_pos(crosshair_pos : Vector2) -> Vector2:
	var to_crosshair : Vector2 = crosshair_pos - global_position;
	var view_amount : float = min(to_crosshair.length() / MaxViewDistance, 1.0);
	
	var target_pos : Vector2 = global_position + (to_crosshair.normalized() * MaxViewDistance * view_amount);
	
	return target_pos;


func process_movement(delta : float) -> void:
	
	var move_dir : Vector2 = Vector2.ZERO;
	if(Input.is_action_pressed("up")):
		move_dir.y -= 1;
	if(Input.is_action_pressed("down")):
		move_dir.y += 1;
	if(Input.is_action_pressed("left")):
		move_dir.x -= 1;
	if(Input.is_action_pressed("right")):
		move_dir.x += 1;
	move_dir = move_dir.normalized();
	
	
	if(move_dir == Vector2.ZERO):
		move_dir = (velocity * -1).normalized();
	
	#var friction_amount : float = 1 - ((move_dir.dot(velocity.normalized()) + 1) / 2);
	
	var force : float = AccelerationRamp.sample_baked(min(velocity.length() / TargetSpeed, 1.0)) * Acceleration * delta;
	var target_velocity : Vector2 = velocity + (move_dir * force);
	
	if(target_velocity.normalized().dot(velocity.normalized()) <= TurningPoint and velocity != Vector2.ZERO):
		velocity = Vector2.ZERO;
	else:
		velocity = target_velocity;
	
	
	move_and_slide();
