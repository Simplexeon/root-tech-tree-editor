# Root Tech Tree Editor ![Plugin logo](/addons/root-tech-tree-editor/assets/root_icon.svg)

- [Installation](#installation)
- [Overview](#overview)
- [Features](#features)
- [Documentation](#documentation)
	- [TechTreeRoot](#techtreeroot)
 	- [TechTreeNode](#techtreenode)
 	- [TechTreeData](#techtreedata)

## Installation
To install this plugin, place everything in the addons/ folder into your own project's addons folder. If there isn't an addons folder in your project, create one!

## Overview
Root Tech Tree Editor is an open-source Godot plugin that lets developers and designers easily create all sorts of different tech trees for their project. 
Because Root is intended to be a generic tech tree implementation, users are expected to design their tech tree UI themselves. A simple example UI can be found in the demo project, which can be imported by downloading this repo. 

[Node in editor](/Assets/Screenshots/root-in-scenetree.png)
Root provides a new custom node to Godot, labelled TechTreeRoot. This node can be interfaced with to interact with the tech tree and read its data. It allows you to load a tech tree file, unlock nodes, and also save modified tech tree data. 
[Editor view](/Assets/Screenshots/editor.png)
Root also provides a new main screen, the Tech Tree Editor. This allows users to easily edit and save their tech trees within the Godot editor.

## Features

### Supported Tree Types
- Any-parent unlocks nodes
- All parents needed to unlock nodes
- Tree progress unlocks nodes

### Tree Features
- Multi-root trees
- Multiple parents to nodes
- Multi-upgradable nodes
- Saving and loading data
- Custom additional node data

## Documentation

### TechTreeRoot
![Plugin logo](/addons/root-tech-tree-editor/assets/root_icon.svg)
This node is used to interface with the Root plugin. It can be used to get tree information, as well as load and save tree data.

#### Signals

```tree_loaded(tree_root : TechTreeRoot)```

This signal is emitted when the tree has loaded new data.
#### Properties

```nodes : Dictionary(int | TechTreeNode)  Read-Only```

Stores all of the nodes in the loaded tech tree. Allows users to access any node in the tech tree with the node's ID. 

```base_nodes : Array[TechTreeNode]  Read-Only```

Stores a direct reference to all root nodes of the tree.

#### Methods

```func is_node_unlockable(node : TechTreeNode) -> bool:```

Used to check if an individual node is unlockable.

```func load_data(data : TechTreeData) -> void:```

Load a [TechTreeData](#techtreedata) resource into this node.

```func extract_data() -> TechTreeData:```

Get the data from the tech tree to store into a new file.

### TechTreeNode
Stores a node's data. 

#### Signals

```tier_unlocked(new_tier : int)```

Emits when a tier has been unlocked.

```tier_reverted(removed_tier : int, new_tier : int)```

Emits when the node has been downgraded and is now on a lower tier.

#### Enumerators

```
enum AvailabilityRequirement {
	OneParent,
	AllParents,
	TreeProgress
}
```

The different ways the node can be unlocked.
- OneParent | Only one parent needs to be unlocked to make this node unlockable.
- AllParents | All parents must be unlocked to make this node unlockable.
- TreeProgress | The tree must have a certain amount of points in it to make this node unlockable. Point minimum is determined by availability_min.

#### Properties

```tech_tree_root : TechTreeRoot  Read-Only```

The [TechTreeRoot](#techtreeroot) this node is loaded in.


```name : String```

Name of the node.

```description : String```

Description of the node.

```index : int```

ID of the node.

```availability : AvailabilityRequirement```

The way the node becomes unlockable.

```availability_min : int```

Used to check if the node is unlockable when the node is unlocked via TreeProgress.

```tiers : int```

Number of times this node can be unlocked / upgraded.

```unlocked_tiers : int```

The current number of unlocked tiers.

```tier_values : Array[int]```

An array containing the point values needed to unlock each tier.

```additional_data : Dictionary(String | String)```

A dictionary storing any additional data added to the node.

#### Methods

```func get_next_tier_cost() -> int:```

How much the next tier costs to unlock. Returns -1 if the node can't be upgraded.

```func unlock_next_tier() -> int:```

Unlocks the next tier and returns how much it cost to unlock. Returns -1 if the node can't be upgraded.

```func get_data() -> Dictionary(String | Variant):```

Get the data in the node in the form of a dictionary.
Dictionary is formatted as so:
{
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
}

```func load_data(data : Dictionary(String | Variant)) -> void:```

Load data from a dictionary formatted in the same way as the get_data method returns.

### TechTreeData

#### Properties

```data : Dictionary(String | Variant)```

The dictionary data used to load a node.
