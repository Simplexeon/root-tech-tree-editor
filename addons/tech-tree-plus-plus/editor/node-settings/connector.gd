@tool
extends TextureRect
class_name TechTreeEditorConnector

# Signals

signal connect_with(connector : TechTreeEditorConnector, other : TechTreeEditorConnector);
signal disconnect_from(connector : TechTreeEditorConnector, other : TechTreeEditorConnector);


# Properties

@export var Type : ConnectorType;
@export var BaseColor : Color = Color.WHITE;


enum ConnectorType {
	Parent,
	Child
}


# Data

var parent_id : int = 0;

var owner_node : TechTreeNodeEditor;
var mouse_over : bool = false;
var dragging : bool = false;

var connected_to : TechTreeEditorConnector :
	set(value):
		connected_to = value;
		
		if(connected_to):
			Line.set_point_position(1, connected_to.global_position - global_position);

			if(connected_to.modulate != BaseColor):
				modulate = connected_to.modulate;
			else:
				var color : Color = Color.from_ok_hsl(randf_range(0.0, 1.0), 0.7, 0.8);
				modulate = color;


		else:
			Line.set_point_position(1, Vector2.ZERO);
			modulate = BaseColor;

var hovered_connector : TechTreeEditorConnector;


var zoom : Vector2 :
	get:
		var camera : Camera2D = get_viewport().get_camera_2d();
		return camera.zoom;

var camera_pos : Vector2 : 
	get: 
		var viewport : Viewport = get_viewport();
		var camera : Camera2D = viewport.get_camera_2d();
		var world_pos 
		return camera.get_screen_center_position();

var just_connected : bool = false;



# Components

@onready var Line : Line2D = $ConnectionLine;


# Processes

func setup(_type : ConnectorType, _parent_id : int, _owner_node : TechTreeNodeEditor) -> void:
	Type = _type;
	parent_id = _parent_id;
	owner_node = _owner_node;
	

func _input(event: InputEvent) -> void:
	
	if(mouse_over):
		if(event is InputEventMouseButton):
			if(event.button_index == MOUSE_BUTTON_LEFT and !just_connected):
				if(event.is_pressed()):
					dragging = true;
	
	
	if(dragging):
		if(event is InputEventMouse):
			Line.set_point_position(1, (get_canvas_transform().affine_inverse() * 
				event.global_position) - global_position);
		
		if(event is InputEventMouseButton):
			if(event.button_index == MOUSE_BUTTON_LEFT):
				if(event.is_pressed() and !mouse_over):
					
					Line.set_point_position(1, Vector2.ZERO);
					modify_connection();
					
					dragging = false;
			else:
				if(event.is_pressed()):
					Line.set_point_position(1, Vector2.ZERO);
					dragging = false;
	
	


func _on_mouse_entered() -> void:
	mouse_over = true;
	get_tree().call_group(&"GTechTreeConnector", &"_entered_connector", self);


func _on_mouse_exited() -> void:
	mouse_over = false;
	get_tree().call_group(&"GTechTreeConnector", &"_exited_connector", self);


func _entered_connector(other : TechTreeEditorConnector) -> void:
	if(!owner_node):
		return;
	
	if(other != self):
		hovered_connector = other;

func _exited_connector(other : TechTreeEditorConnector) -> void:
	just_connected = false;
	
	if(!owner_node):
		return;
	
	if(other != self):
		hovered_connector = null;
	



# Functions

func update_line() -> void:
	if(connected_to):
		Line.set_point_position(1, connected_to.global_position - global_position);
		

func modify_connection() -> void:
	
	if(hovered_connector):
		if(hovered_connector.Type != Type and hovered_connector.parent_id != parent_id):
			if(connected_to and connected_to != hovered_connector):
				disconnect_from.emit(self, connected_to);
			
			if(hovered_connector.connected_to):
				hovered_connector.disconnect_from.emit(hovered_connector, 
					hovered_connector.connected_to);
			
			connect_with.emit(self, hovered_connector);
			just_connected = true;
	else:
		if(connected_to):
			disconnect_from.emit(self, connected_to);
		
