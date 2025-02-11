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

var next_nodes : Array[TechTreeNode];
var parent_nodes : Array[TechTreeNode];

# Number of upgradable levels of the node
var tiers : int;

# Number of unlocked tiers
var unlocked_tiers : int;

# The unlock requirements for each tier of the tech tree
# Dictionary for each tier to allow for multiple resources
var unlock_requirements : Array[Dictionary];

# When this node becomes available to be unlocked
var availability : AvailabilityRequirement;

# A number to be used with the availability
# If availability is tree progress, this is the amount of
# progress needed to be available.
var availability_min : int;


# Processes

func _init() -> void:
	next_nodes = [];
	parent_nodes = [];
	
	tiers = 1;
	unlocked_tiers = 0;
	
	unlock_requirements = [{
		"points": 1
	}];
	
	availability = AvailabilityRequirement.OneParent;


# Functions

func connect_next_node(next : TechTreeNode) -> void:
	
	next.add_parent_node(self);
	next_nodes.append(next);
	

func add_parent_node(parent : TechTreeNode) -> void:
	parent_nodes.append(parent);
