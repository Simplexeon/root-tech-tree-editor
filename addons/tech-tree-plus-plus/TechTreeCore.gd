@tool
extends EditorPlugin

# Properties


# Files

const core_icon : Texture2D = preload("res://addons/tech-tree-plus-plus/core_icon.svg");
const core_script : Script = preload("res://addons/tech-tree-plus-plus/TechTreeRoot.gd");


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	
	add_custom_type("TechTreeCore", "Node", core_script, core_icon);


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
