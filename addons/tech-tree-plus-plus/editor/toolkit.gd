@tool
extends PanelContainer


# Properties


@export_subgroup("Elements")
@export var AddNodeButton : Button;
@export var EditorArea : Node2D;
@export var SaveButton : Button;
@export var LoadButton : Button;

@export_subgroup("Files")
@export var NodeEditorScene : PackedScene;


# Data

var next_node_id : int = 1;

var nodes : Dictionary;
var node_editors : Dictionary;
var root_nodes : Array[int];


# Processes

func _ready() -> void:
	
	nodes = {};
	node_editors = {};
	root_nodes = [];
	
	# Setup UI
	
	if(AddNodeButton):
		AddNodeButton.pressed.connect(add_node);
	
	if(SaveButton):
		SaveButton.pressed.connect(start_picking_folder);


# Functions

func add_node() -> void:
	if(NodeEditorScene.can_instantiate() and EditorArea):
		
		var node_editor : TechTreeNodeEditor = NodeEditorScene.instantiate();
		EditorArea.add_child(node_editor);
		node_editor.global_position = Vector2.ZERO;
		node_editor.connections_changed.connect(node_connections_changed);
		node_editor.data_changed.connect(node_data_changed);
		
		node_editor.setup(next_node_id);
		node_editors[next_node_id] = node_editor;
		
		next_node_id += 1;
		
		nodes[node_editor.data.index] = node_editor.data.get_data();
		root_nodes.append(node_editor.data.index);
		


func node_connections_changed(node : TechTreeNodeEditor, parents : Array[int], 
	next_nodes : Array[int]):
	
	node_data_changed(node.data);
	
	var root_location : int = root_nodes.find(node.data.index);
	
	if(root_location != -1):
		
		if(parents.size() > 0):
			root_nodes.remove_at(root_location);
		
	else:
		if(parents.size() == 0):
			root_nodes.append(node.data.index);
	

func node_data_changed(data : TechTreeNode) -> void:
	nodes[data.index] = data.get_data();
	


func start_picking_folder() -> void:
	
	var popup : EditorFileDialog = EditorFileDialog.new();
	popup.access = EditorFileDialog.ACCESS_FILESYSTEM;
	popup.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE;
	popup.add_filter("*.tres, *.res", "Resource File");
	
	add_child(popup);
	
	popup.popup_file_dialog();
	popup.file_selected.connect(func (dir : String):
		save(dir);
		popup.queue_free();
		);


func save(location : String) -> void:
	
	var resource : TechTreeData = TechTreeData.new();
	resource.data = {
		"node_data": nodes,
		"root_nodes": root_nodes,
	};
	
	if(ResourceSaver.save(resource, location) != OK):
		print_rich("[color=red]Error saving file.[/color]");
	else:
		print_rich("[color=green]Successfully saved tree data at " + location + "[/color]");
	

func load_tree(location : String) -> void:
	
	var result : Resource = ResourceLoader.load(location);
	
	if(result is TechTreeData):
		load_dict(result.data);


func load_dict(data : Dictionary) -> void:
	
	var node_data = data["node_data"];
	root_nodes = data["root_nodes"];
	
	# Load all of the nodes
	var largest_id : int = 0;
	for node in node_data:
		
		var node_editor : TechTreeNodeEditor = NodeEditorScene.instantiate();
		EditorArea.add_child(node_editor);
		node_editor.connections_changed.connect(node_connections_changed);
		node_editor.data_changed.connect(node_data_changed);
		
		node_editor.setup(node_data[node]["index"]);
		node_editors[node_data[node]["index"]] = node_editor;
		
		if(node_data[node]["index"] > largest_id):
			largest_id = node_data[node]["index"];
		
		nodes[node_data[node]["index"]] = node_data[node];
		node_editor.load_from_data(node_data[node]);
	
	# Set next index
	next_node_id = largest_id + 1;
	
	# Connect nodes
	for node in nodes:
		var current_data : Dictionary = nodes[node];
		
		# Connect parents
		for parent in current_data["parents"]:
			node_editors[current_data["index"]].connect_to(node_editors[parent], TechTreeEditorConnector.ConnectorType.Parent);
		
		# Connect children
		for child in current_data["children"]:
			node_editors[current_data["index"]].connect_to(node_editors[child], TechTreeEditorConnector.ConnectorType.Child);
