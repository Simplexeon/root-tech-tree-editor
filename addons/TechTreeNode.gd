extends Object;
class_name TechTreeNode;

# Signals

signal tier_unlocked(new_tier : int);
signal tier_reverted(removed_tier : int, new_tier : int);


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


# Processes

func _init() -> void:
	next_nodes = [];
	parent_nodes = [];
	
	tiers = 1;
	unlocked_tiers = 0;
	
	unlock_requirements = [{
		"points": 1
	}];


# Functions

func connect_next_node(next : TechTreeNode) -> void:
	pass;
