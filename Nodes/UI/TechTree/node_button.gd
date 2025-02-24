extends TextureButton
class_name NodeButton

# Properties

@export var SkillID : int;
@export var RootNode : TechTreeRoot;
@export var TechTreeController : UIController;

@export_subgroup("elements")
@export var BGTextureRect : TextureRect;

@export_subgroup("files")
@export var RegularTexture : Texture2D;
@export var RegularHoverTexture : Texture2D;
@export var RegularPressTexture : Texture2D;
@export var FilledTexture : Texture2D;
@export var FilledHoverTexture : Texture2D;
@export var FilledPressTexture : Texture2D;

@export var Tier1BG : Texture2D;
@export var Tier2BG : Texture2D;
@export var Tier3BG : Texture2D;
@export var Tier4BG : Texture2D;


# Data

var data : TechTreeNode;


# Processes

func _ready() -> void:
	RootNode.tree_loaded.connect(setup);

func setup(_tree_root : TechTreeRoot) -> void:
	
	update_textures();
	data = RootNode.nodes[SkillID];
	
	

func _when_pressed() -> void:
	
	if(RootNode.is_node_unlockable(data)):
		TechTreeController.spend(data.unlock_next_tier());
	
	update_textures();


func _hover() -> void:
	if(TechTreeController):
		TechTreeController.display_info(data);



# Functions

func update_textures() -> void:
	texture_normal = RegularTexture;
	texture_pressed = RegularPressTexture;
	texture_hover = RegularHoverTexture;
	
	
	if(data):
		if(data.unlocked_tiers > 0):
			texture_normal = FilledTexture;
			texture_pressed = FilledPressTexture;
			texture_hover = FilledHoverTexture;
		
		if(BGTextureRect):
			match(data.unlocked_tiers):
				1:
					BGTextureRect.visible = true;
					BGTextureRect.texture = Tier1BG;
				2:
					BGTextureRect.visible = true;
					BGTextureRect.texture = Tier2BG;
				3:
					BGTextureRect.visible = true;
					BGTextureRect.texture = Tier3BG;
				4:
					BGTextureRect.visible = true;
					BGTextureRect.texture = Tier4BG;
				_:
					BGTextureRect.visible = false;
	else:
		if(BGTextureRect):
			BGTextureRect.visible = false;