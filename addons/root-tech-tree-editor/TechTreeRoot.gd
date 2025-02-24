extends Node
class_name TechTreeRoot
# A node to be used to create and interact with a tech tree.


# Signals

signal tree_loaded(tree_root : TechTreeRoot);


# Properties


# Data

# Stores all tech tree nodes based on the 
# node's index.
# int | TechTreeNode
var nodes : Dictionary = {};

# Stores a reference to the root nodes in the tree
var base_nodes : Array[TechTreeNode] = [];

var tree_progress : int = 0;


# Processes

func _enter_tree() -> void:
	pass;

func _ready() -> void:
	pass;


# Functions


func is_node_unlockable(node : TechTreeNode) -> bool:
	
	if(base_nodes.has(node)):
		return true;
	
	match(node.availability):
		TechTreeNode.AvailabilityRequirement.OneParent:
			
			for parent in node.parent_nodes:
				if(nodes[parent].unlocked_tiers > 0):
					return true;
			
			return false;
		
		TechTreeNode.AvailabilityRequirement.AllParents:
			
			for parent in node.parent_nodes:
				if(nodes[parent].unlocked_tiers <= 0):
					return false;
			
			return true;
		
		TechTreeNode.AvailabilityRequirement.TreeProgress:
			
			if(tree_progress >= node.availability_min):
				return true;
			return false;
	
	print_rich("[color=red]ERROR: Invalid node availability requriment. Possible file corruption.[/color]");
	return false;


func load_data(data : TechTreeData) -> void:
	
	var node_data = data.data["node_data"];
	var root_nodes = data.data["root_nodes"].duplicate();
	
	# Load all of the nodes
	for node in node_data:
		
		var new_node : TechTreeNode = TechTreeNode.new();
		new_node.load_data(node_data[node]);
		new_node.tech_tree_root = self;
		
		nodes[new_node.index] = new_node;
		
		var i : int = 0;
		while(i < new_node.unlocked_tiers):
			tree_progress += new_node.tier_values[i];
			
			i += 1;
	
	base_nodes.resize(root_nodes.size());
	
	var i : int = 0;
	for node in root_nodes:
		base_nodes[i] = nodes[node];
		i += 1;
	
	
	tree_loaded.emit(self);


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
