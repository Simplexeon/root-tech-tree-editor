@tool
extends PanelContainer
class_name TechTreeNodeEditor

# Properties

@export_subgroup("Elements")
@export var DragTab : Button;
@export var ParentConnectorContainer : Control;
@export var ChildConnectorContainer : Control;
@export var AddParentButton : Button;
@export var AddChildButton : Button;
@export var TierCountBox : SpinBox;
@export var UnlockDropdown : OptionButton;
@export var ProgressRequirementBox : SpinBox;

@export_subgroup("Files")
@export var ConnectorFile : PackedScene;



# Data

var data : TechTreeNode;

var zoom : Vector2 :
	get: 
		var camera : Camera2D = get_viewport().get_camera_2d();
		return camera.zoom;


# Processes

func _ready() -> void:
	
	# Setup data
	
	data = TechTreeNode.new();
	
	
	# Setup UI
	
	if(AddParentButton):
		AddParentButton.pressed.connect(add_parent_connector);
	
	if(AddChildButton):
		AddChildButton.pressed.connect(add_child_connector);
	
	if(TierCountBox):
		TierCountBox.value_changed.connect(func (value : float): set_tiers(int(value)));
	
	if(UnlockDropdown):
		UnlockDropdown.item_selected.connect(func (index : int):
			set_unlock_requirement(index as TechTreeNode.AvailabilityRequirement));
	
	if(ProgressRequirementBox):
		ProgressRequirementBox.value_changed.connect(func (value : float): 
			set_progress_requirement(int(value)));
	
	pass;

func setup(index : int) -> void:
	data.set_id(index);
	
	if(ParentConnectorContainer):
		for connector in ParentConnectorContainer.get_children():
			connector.parent_id = index;

func _on_drag_tab_move(relative:Vector2) -> void:
	position += relative * (1.0 / zoom.x);
	

# Functions

func add_parent_connector() -> void:
	
	if(ConnectorFile.can_instantiate() and ParentConnectorContainer):
		var connector : TechTreeEditorConnector = ConnectorFile.instantiate();
		connector.setup(TechTreeEditorConnector.ConnectorType.Parent, data.index);
		
		ParentConnectorContainer.add_child(connector);
	


func add_child_connector() -> void:
	
	if(ConnectorFile.can_instantiate() and ChildConnectorContainer):
		var connector : TechTreeEditorConnector = ConnectorFile.instantiate();
		connector.setup(TechTreeEditorConnector.ConnectorType.Child, data.index);
		
		ChildConnectorContainer.add_child(connector);
	


func set_tiers(tier_count : int) -> void:
	data.tiers = tier_count;

func set_unlock_requirement(unlock_requirement : TechTreeNode.AvailabilityRequirement) -> void:
	data.availability = unlock_requirement;
	
	if(ProgressRequirementBox):
		data.availability_min = ProgressRequirementBox.value;
	

func set_progress_requirement(amount : int) -> void:
	data.availability_min = amount;

