@tool
extends EditorPlugin

# Properties




func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	
	# Files
	
	var core_icon : Texture2D = load("res://addons/tech-tree-plus-plus/core_icon.svg");
	var core_script : Script = load("res://addons/tech-tree-plus-plus/TechTreeRoot.gd");
	
	await core_icon;
	await core_script;
	
	add_custom_type("TechTreeCore", "Node", core_script, core_icon);


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
