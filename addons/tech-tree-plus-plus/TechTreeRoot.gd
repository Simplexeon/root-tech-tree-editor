extends Node
class_name TechTreeRoot
# A node to be used to create and interact with a tech tree.


# Properties


# Data

var base_nodes : Array[TechTreeNode] = [];


# Processes

func _enter_tree() -> void:
	pass;

func _ready() -> void:
	pass;


# Functions

func create_node() -> TechTreeNode:
	var node : TechTreeNode = TechTreeNode.new();
	
	return node;

func add_base(node : TechTreeNode) -> void:
	base_nodes.append(node);
