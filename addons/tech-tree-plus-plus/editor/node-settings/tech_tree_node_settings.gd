@tool
extends PanelContainer
class_name TechTreeNodeEditor

# Properties

@export_subgroup("Elements")
@export var DragTab : Button;
@export var DeleteButton : Button;
@export var ParentConnectorContainer : Control;
@export var ChildConnectorContainer : Control;
@export var AddParentButton : Button;
@export var AddChildButton : Button;
@export var UnlockDropdown : OptionButton;
@export var ProgressRequirementContainer : Control;
@export var ProgressRequirementBox : SpinBox;
@export var TierCountBox : SpinBox;
@export var TierCostContainer : Control;

@export_subgroup("Files")
@export var ConnectorFile : PackedScene;
@export var TierCostControlFile : PackedScene;



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
	
	if(ProgressRequirementContainer):
		ProgressRequirementContainer.visible = false;
	
	if(ProgressRequirementBox):
		ProgressRequirementBox.value_changed.connect(func (value : float): 
			set_progress_requirement(int(value)));
	
	if(DeleteButton):
		DeleteButton.pressed.connect(delete);
	pass;

func setup(index : int) -> void:
	data.set_id(index);
	
	if(ParentConnectorContainer):
		for connector in ParentConnectorContainer.get_children():
			connector.setup(TechTreeEditorConnector.ConnectorType.Parent, data.index, self);
			connector.connect_with.connect(connect_with);
			connector.disconnect_from.connect(disconnect_from);

func _on_drag_tab_move(relative : Vector2) -> void:
	global_position += relative * (1.0 / zoom.x);
	
	update_connectors();



# Functions

func delete() -> void:
	if(ParentConnectorContainer):
		for connector in ParentConnectorContainer.get_children():
			if(connector.connected_to):
				disconnect_from(connector, connector.connected_to);
	
	if(ChildConnectorContainer):
		for connector in ChildConnectorContainer.get_children():
			if(connector.connected_to):
				disconnect_from(connector, connector.connected_to);
	
	queue_free();

func add_parent_connector() -> void:
	
	if(ConnectorFile.can_instantiate() and ParentConnectorContainer):
		var connector : TechTreeEditorConnector = ConnectorFile.instantiate();
		connector.setup(TechTreeEditorConnector.ConnectorType.Parent, data.index, self);
		connector.connect_with.connect(connect_with);
		connector.disconnect_from.connect(disconnect_from);
		
		ParentConnectorContainer.add_child(connector);
	
	call_deferred(&"update_connectors");


func add_child_connector() -> void:
	
	if(ConnectorFile.can_instantiate() and ChildConnectorContainer):
		var connector : TechTreeEditorConnector = ConnectorFile.instantiate();
		connector.setup(TechTreeEditorConnector.ConnectorType.Child, data.index, self);
		connector.connect_with.connect(connect_with);
		connector.disconnect_from.connect(disconnect_from);
		
		ChildConnectorContainer.add_child(connector);
	
	call_deferred(&"update_connectors");
		
	

func connect_with(base: TechTreeEditorConnector, other : TechTreeEditorConnector) -> void:
	base.connected_to = other;
	other.connected_to = base;
	
	if(base.Type == TechTreeEditorConnector.ConnectorType.Parent):
		other.owner_node.data.parent_nodes.append(data);
		data.next_nodes.append(other.owner_node.data);
	else:
		other.owner_node.data.next_nodes.append(data);
		data.parent_nodes.append(other.owner_node.data);

func disconnect_from(base: TechTreeEditorConnector, other : TechTreeEditorConnector) -> void:
	base.connected_to = null;
	other.connected_to = null;
	
	if(base.Type == TechTreeEditorConnector.ConnectorType.Parent):
		other.owner_node.data.parent_nodes.erase(data);
		data.next_nodes.erase(other.owner_node.data);
	else:
		other.owner_node.data.next_nodes.erase(data);
		data.parent_nodes.erase(other.owner_node.data);


func update_connectors() -> void:
	
	if(ParentConnectorContainer):
		for connector in ParentConnectorContainer.get_children():
			connector.update_line();
			if(connector.connected_to):
				connector.connected_to.update_line();
	
	
	if(ChildConnectorContainer):
		for connector in ChildConnectorContainer.get_children():
			connector.update_line();
			if(connector.connected_to):
				connector.connected_to.update_line();


func set_tiers(tier_count : int) -> void:
	data.tiers = tier_count;
	
	if(TierCostContainer):
		var count : int = TierCostContainer.get_child_count();
		while(tier_count > count):
			var tier_cost : TechTreeEditorTierCost = TierCostControlFile.instantiate();
			TierCostContainer.add_child(tier_cost);
			tier_cost.setup(count);
			tier_cost.tier_cost_changed.connect(tier_cost_changed);
			
			data.unlock_requirements.append(0);
			
			count += 1;
		
		var tier_cost_container_children : Array[Node] = TierCostContainer.get_children();
		while(tier_count < count):
			TierCostContainer.remove_child(tier_cost_container_children[count - 1]);
			tier_cost_container_children[count - 1].queue_free();
			
			data.unlock_requirements.pop_back();
			
			count -= 1;


func tier_cost_changed(tier_index : int, cost : int) -> void:
	data.unlock_requirements[tier_index] = cost;

func set_unlock_requirement(unlock_requirement : TechTreeNode.AvailabilityRequirement) -> void:
	data.availability = unlock_requirement;
	
	if(unlock_requirement == TechTreeNode.AvailabilityRequirement.TreeProgress):
		if(ProgressRequirementContainer):
			ProgressRequirementContainer.visible = true;
	elif(ProgressRequirementContainer):
		ProgressRequirementContainer.visible = false;
	
	
	if(ProgressRequirementBox):
		data.availability_min = ProgressRequirementBox.value;
	

func set_progress_requirement(amount : int) -> void:
	data.availability_min = amount;
