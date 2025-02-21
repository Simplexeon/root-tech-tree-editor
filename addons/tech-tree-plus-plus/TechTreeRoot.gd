extends Node
class_name TechTreeRoot
# A node to be used to create and interact with a tech tree.


# Properties


# Data

# Stores all tech tree nodes based on the 
# node's index.
# int | TechTreeNode
var nodes : Dictionary = {};

# Stores a reference to the root nodes in the tree
var base_nodes : Array[TechTreeNode] = [];


# Processes

func _enter_tree() -> void:
	pass;

func _ready() -> void:
	pass;


# Functions

func load_data(data : TechTreeData) -> void:
	
	var node_data = data.data["node_data"];
	var root_nodes = data.data["root_nodes"].duplicate();
	
	# Load all of the nodes
	for node in node_data:
		
		var new_node : TechTreeNode = TechTreeNode.new();
		new_node.load_data(node_data[node]);
		
		nodes[new_node.index] = new_node;
	
	base_nodes.resize(root_nodes.size());
	
	var i : int = 0;
	for node in root_nodes:
		base_nodes[i] = nodes[node];
		i += 1;

func extract_data() -> TechTreeData:
	
	var node_dict : Dictionary = {};
	for id in nodes:
		node_dict[id] = nodes[id].get_data();
	
	var base_node_ids : Array[int] = [];
	base_node_ids.resize(base_nodes.size());
	var i : int = 0;
	for node in base_nodes:
		base_node_ids[i] = node.index;
		i += 1;
	
	var data : TechTreeData = TechTreeData.new();
	data.data = {
		"node_data": node_dict,
		"root_nodes": base_node_ids,
	}
	
	return data;

func create_node() -> TechTreeNode:
	var node : TechTreeNode = TechTreeNode.new();
	
	return node;

func add_base(node : TechTreeNode) -> void:
	base_nodes.append(node);
