@tool
extends EditorPlugin

# Properties


# Data

var main_panel_inst : Control;


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	
	# Files
	
	var core_icon : Texture2D = load("res://addons/tech-tree-plus-plus/core_icon.svg");
	var core_script : Script = load("res://addons/tech-tree-plus-plus/TechTreeRoot.gd");
	
	var main_panel_file : PackedScene = load("res://addons/tech-tree-plus-plus/editor/TechTreeEditor.tscn");
	
	await core_icon;
	await core_script;
	await main_panel_file;
	
	# Tech tree node
	add_custom_type("TechTreeRoot", "Node", core_script, core_icon);
	
	
	# Editor
	
	main_panel_inst = main_panel_file.instantiate();
	
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel_inst);
	_make_visible(false);



func _exit_tree() -> void:
	# Clean-up of the plugin
	if(main_panel_inst):
		main_panel_inst.queue_free();

func _has_main_screen() -> bool:
	return true;


func _make_visible(visible) -> void:
	if(main_panel_inst):
		main_panel_inst.visible = visible;


func _get_plugin_name() -> String:
	return "TechTreePlusPlus";


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("GraphEdit", "EditorIcons");
