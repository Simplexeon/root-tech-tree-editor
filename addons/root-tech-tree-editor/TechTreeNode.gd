@tool
extends Object;
class_name TechTreeNode;
# Stores information for an individual node in a tech tree.

# Signals

signal tier_unlocked(new_tier : int);
signal tier_reverted(removed_tier : int, new_tier : int);


# Enums

enum AvailabilityRequirement {
	OneParent,
	AllParents,
	TreeProgress
}


# Data

var next_nodes : Array[int];
var parent_nodes : Array[int];

var tech_tree_root : TechTreeRoot;


# Name of node
var name : String;

# Unique index
var index : int;

# When this node becomes available to be unlocked
var availability : AvailabilityRequirement;

# A number to be used with the availability
# If availability is tree progress, this is the amount of
# progress needed to be available.
var availability_min : int;

# Number of upgradable levels of the node
var tiers : int;

# Number of unlocked tiers
var unlocked_tiers : int;

# The unlock requirements for each tier of the tech tree
# Dictionary for each tier to allow for multiple resources
var tier_values : Array[int];

var description : String;

var additional_data : Dictionary;


# Editor-only Data

var editor_pos : Vector2;



# Processes

func _init() -> void:
	next_nodes = [];
	parent_nodes = [];
	
	name = "Node Name";
	description = "desc";
	
	index = 0;
	
	tiers = 0;
	unlocked_tiers = 0;
	
	tier_values = [];
	
	availability = AvailabilityRequirement.OneParent;
	additional_data = {};
	
	editor_pos = Vector2.ZERO;


# Functions

func get_next_tier_cost() -> int:
	
	if(unlocked_tiers < tiers):
		return tier_values[unlocked_tiers];
	
	# Return -1 if no next tier to unlock
	return -1; 

func unlock_next_tier() -> int:
	
	var cost : int = get_next_tier_cost();
	if(cost >= 0):
		unlocked_tiers += 1;
		tech_tree_root.tree_progress += cost;
	
	return cost;
	


func set_id(id : int) -> void:
	index = id;

func connect_next_node(next : TechTreeNode) -> void:
	
	next.add_parent_node(self);
	next_nodes.append(next.index);
	

func add_parent_node(parent : TechTreeNode) -> void:
	parent_nodes.append(parent.index);


# Get all of the node data
# Common usage in saving or printing to console
func get_data() -> Dictionary:
	
	return {
		"name": name,
		"description": description,
		"index": index,
		"parents": parent_nodes,
		"children": next_nodes,
		"availability": AvailabilityRequirement.keys()[availability],
		"progress_min": availability_min,
		"tiers": tiers,
		"unlocked_tiers": unlocked_tiers,
		"tier_values": tier_values,
		"additional_data": additional_data,
		
		"editor_pos": editor_pos,
	};


func load_data(data : Dictionary) -> void:
	
	name = data["name"];
	index = data["index"];
	parent_nodes = data["parents"];
	next_nodes = data["children"];
	availability = AvailabilityRequirement[data["availability"]];
	availability_min = data["progress_min"];
	tiers = data["tiers"];
	unlocked_tiers = data["unlocked_tiers"];
	tier_values = data["tier_values"];
	description = data["description"];
	additional_data = data["additional_data"];
	
	editor_pos = data["editor_pos"];
	
	pass; 