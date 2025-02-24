@tool
extends VBoxContainer
class_name RootTechTreeEditorAdditionalDataSettings

# Signals

signal data_changed(data : Dictionary);


# Properties

@export var TextTimeout : float;

@export_subgroup("Elements")
@export var NameEdit : LineEdit;
@export var DataEdit : TextEdit;


# Data

var timer : Timer;


# Processes

func _ready() -> void:
	timer = Timer.new();
	timer.wait_time = TextTimeout;
	timer.one_shot = true;
	timer.timeout.connect(_text_timeout_finished);
	add_child(timer);
	

func _text_changed() -> void:
	timer.stop();
	timer.start();

func _text_timeout_finished() -> void:
	data_changed.emit(get_data());


func fill_data(name : String, data : String) -> void:
	if(NameEdit):
		NameEdit.text = name;
	
	if(DataEdit):
		DataEdit.text = data;

func get_data() -> Dictionary:
	return {
		"name": NameEdit.text,
		"data": DataEdit.text
	}