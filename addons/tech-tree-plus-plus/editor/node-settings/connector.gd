@tool
extends TextureRect
class_name TechTreeEditorConnector

# Signals

signal connect_with(other : TechTreeEditorConnector);
signal disconnect(other : TechTreeEditorConnector);


# Properties

@export var Type : ConnectorType;


enum ConnectorType {
	Parent,
	Child
}


# Data

var parent_id : int = 0;

var mouse_over : bool = false;
var dragging : bool = false;

var connected_to : TechTreeEditorConnector :
	set(value):
		connected_to = value;
		
		if(connected_to):
			Line.set_point_position(1, connected_to.global_position - global_position);
		else:
			Line.set_point_position(1, Vector2.ZERO);

var hovered_connector : TechTreeEditorConnector;


var zoom : Vector2 :
	get:
		var camera : Camera2D = get_viewport().get_camera_2d();
		return camera.zoom;

var camera_pos : Vector2 : 
	get: 
		var camera : Camera2D = get_viewport().get_camera_2d();
		return camera.get_screen_center_position();


# Components

@onready var Line : Line2D = $ConnectionLine;


# Processes

func setup(_type : ConnectorType, _parent_id : int) -> void:
	Type = _type;
	parent_id = _parent_id;
	

func _input(event: InputEvent) -> void:
	
	if(dragging):
		if(event is InputEventMouse):
			Line.set_point_position(1, (event.global_position * (1.0 / zoom.x)) + camera_pos - global_position);
		
		if(event is InputEventMouseButton):
			if(event.button_index == MOUSE_BUTTON_LEFT):
				if(event.is_pressed()):
					
					Line.set_point_position(1, Vector2.ZERO);
					modify_connection();
					
					dragging = false;
			else:
				if(event.is_pressed()):
					dragging = false;
	
	
	if(mouse_over):
		if(event is InputEventMouseButton):
			if(event.button_index == MOUSE_BUTTON_LEFT):
				if(event.is_pressed()):
					dragging = true;


func _on_mouse_entered() -> void:
	mouse_over = true;
	get_tree().call_group(&"GTechTreeConnector", &"_entered_connector", self);


func _on_mouse_exited() -> void:
	mouse_over = false;
	get_tree().call_group(&"GTechTreeConnector", &"_exited_connector", self);


func _entered_connector(other : TechTreeEditorConnector) -> void:
	hovered_connector = other;

func _exited_connector(other : TechTreeEditorConnector) -> void:
	hovered_connector = null;


func _zoom_changed(_zoom : Vector2) -> void:
	zoom = _zoom;

func _camera_moved(_new_pos : Vector2) -> void:
	pass;


# Functions

func modify_connection() -> void:
	
	if(hovered_connector):
		if(hovered_connector.Type != Type and hovered_connector.parent_id != parent_id):
			if(connected_to and connected_to != hovered_connector):
				disconnect.emit(connected_to);
			
			connect_with.emit(hovered_connector);