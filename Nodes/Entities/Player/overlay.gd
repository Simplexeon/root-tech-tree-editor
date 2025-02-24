extends Control
class_name UIController;


# Parameters

@export var TreeFile : TechTreeData;

@export_subgroup("Elements")
@export var TreeRoot : TechTreeRoot;
@export var NodeTitle : RichTextLabel;
@export var NodeDescription : RichTextLabel;
@export var SpentAmountDisplay : RichTextLabel;


# Data

var spent_amount : int = 0;


# Processes

func _ready() -> void:
	TreeRoot.load_data(TreeFile);
	


# Functions

func spend(amount : int) -> void:
	if(amount > 0):
		spent_amount += amount;
	SpentAmountDisplay.text = "Spent Points: " + str(spent_amount);

func display_info(node : TechTreeNode) -> void:
	
	if(NodeTitle and NodeDescription):
		NodeTitle.text = node.name;
		NodeDescription.text = node.description;
	
