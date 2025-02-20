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


# Editor-only Data

var editor_pos : Vector2;



# Processes

func _init() -> void:
	next_nodes = [];
	parent_nodes = [];
	
	name = "Node Name";
	
	index = 0;
	
	tiers = 0;
	unlocked_tiers = 0;
	
	tier_values = [];
	
	availability = AvailabilityRequirement.OneParent;
	
	
	editor_pos = Vector2.ZERO;


# Functions

func set_id(id : int) -> void:
	index = id;

func connect_next_node(next : TechTreeNode) -> void:
	
	next.add_parent_node(self);
	next_nodes.append(next);
	

func add_parent_node(parent : TechTreeNode) -> void:
	parent_nodes.append(parent);


# Get all of the node data
# Common usage in saving or printing to console
func get_data() -> Dictionary:
	
	return {
		"name": name,
		"index": index,
		"parents": parent_nodes,
		"children": next_nodes,
		"availability": AvailabilityRequirement.keys()[availability],
		"progress_min": availability_min,
		"tiers": tiers,
		"tier_values": tier_values,
		
		"editor_pos": editor_pos,
	};
