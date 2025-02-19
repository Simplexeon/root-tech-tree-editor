@tool
extends HBoxContainer
class_name TechTreeEditorTierCost

# Signals

signal tier_cost_changed(tier_index : int, cost : int);


# Properties

@export var LabelText : String = "Tier ";
@export var LabelTextSuffix : String = " Cost: ";

@export_subgroup("Elements")
@export var Name : RichTextLabel;
@export var Counter : SpinBox;


# Data

var tier_index : int;
var cost : int;


# Processes

func setup(_tier_index : int) -> void:
	
	tier_index = _tier_index;
	
	if(Name):
		Name.text = LabelText + str(tier_index) + LabelTextSuffix;
	
	if(Counter):
		Counter.value_changed.connect(func (value : float): set_cost(int(value)));


# Functions

func set_cost(amount : int) -> void:
	cost = amount;
	
	tier_cost_changed.emit(tier_index, cost);