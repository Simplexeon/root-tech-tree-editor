@tool
extends PanelContainer
class_name TechTreeNodeEditor

# Signals

signal connections_changed(node : TechTreeNodeEditor, 
	parents : Array[int], children : Array[int]);

signal data_changed(data : TechTreeNode);


# Properties

@export_subgroup("Elements")
@export var DragTab : Button;
@export var DeleteButton : Button;
@export var TitleField : LineEdit;
@export var IDLabel : RichTextLabel;
@export var ParentConnectorContainer : Control;
@export var ChildConnectorContainer : Control;
@export var AddParentButton : Button;
@export var AddChildButton : Button;
@export var UnlockDropdown : OptionButton;
@export var ProgressRequirementContainer : Control;
@export var ProgressRequirementBox : SpinBox;
@export var TierCountBox : SpinBox;
@export var TierCostContainer : Control;
@export var NodeDescriptionEdit : TextEdit;
@export var AdditionalDataCountBox : SpinBox;
@export var AdditionalDataContainer : VBoxContainer;

@export_subgroup("Files")
@export var ConnectorFile : PackedScene;
@export var TierCostControlFile : PackedScene;
@export var AdditionalDataControlFile : PackedScene;



# Data

var data : TechTreeNode;

var zoom : Vector2 :
	get: 
		var camera : Camera2D = get_viewport().get_camera_2d();
		return camera.zoom;


# Processes

func _ready() -> void:
	
	# Setup data
	
	if(!data):
		data = TechTreeNode.new();
	
	
	# Setup UI
	
	if(TitleField):
		TitleField.text_changed.connect(change_name);
	
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
	
	if(NodeDescriptionEdit):
		NodeDescriptionEdit.text_changed.connect(func (): description_changed(NodeDescriptionEdit.text));
	
	if(AdditionalDataCountBox):
		AdditionalDataCountBox.value_changed.connect(func (value : float): set_additional_data(int(value)));

func setup(index : int) -> void:
	data.set_id(index);
	
	if(IDLabel):
		IDLabel.text = "ID: " + str(index);
	
	if(ParentConnectorContainer):
		for connector in ParentConnectorContainer.get_children():
			connector.setup(TechTreeEditorConnector.ConnectorType.Parent, data.index, self);
			connector.connect_with.connect(connect_with);
			connector.disconnect_from.connect(disconnect_from);

func _on_drag_tab_move(relative : Vector2) -> void:
	global_position += relative * (1.0 / zoom.x);
	data.editor_pos = global_position;
	
	update_connectors();
	
	data_changed.emit(data);



# Functions

func load_from_data(stored_data : Dictionary) -> void:
	
	data.load_data(stored_data);
	
	
	if(IDLabel):
		IDLabel.text = "ID: " + str(data.index);
	
	if(TitleField):
		TitleField.text = data.name;
	
	if(NodeDescriptionEdit):
		NodeDescriptionEdit.text = data.description;
	
	# CONNECTORS
	
	if(UnlockDropdown):
		UnlockDropdown.selected = data.availability;
	
	if(ProgressRequirementBox):
		ProgressRequirementBox.value = data.availability_min;
		set_unlock_requirement(data.availability);
	
	if(TierCountBox):
		TierCountBox.value = data.tiers;
	
	# FILL TIER DATA
	if(TierCostContainer):
		var i : int = 0;
		for cost in TierCostContainer.get_children():
			if(cost.Counter):
				cost.Counter.value = data.tier_values[i];
			
			i += 1;
	
	
	if(AdditionalDataCountBox):
		AdditionalDataCountBox.value = data.additional_data.size();
	
	# FILL ADDITIONAL DATA
	
	if(AdditionalDataContainer):
		var additional_data_keys : Array = data.additional_data.keys();
		var i : int = 0;
		for additional_data in AdditionalDataContainer.get_children():
			additional_data.fill_data(additional_data_keys[i], 
				data.additional_data[additional_data_keys[i]]);
			
			i += 1;
	
	
	global_position = data.editor_pos;


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


func change_name(new_name : String) -> void:
	data.name = new_name;
	data_changed.emit(data);


func add_parent_connector() -> TechTreeEditorConnector:
	
	var connector : TechTreeEditorConnector;
	if(ConnectorFile.can_instantiate() and ParentConnectorContainer):
		connector = ConnectorFile.instantiate();
		connector.setup(TechTreeEditorConnector.ConnectorType.Parent, data.index, self);
		connector.connect_with.connect(connect_with);
		connector.disconnect_from.connect(disconnect_from);
		
		ParentConnectorContainer.add_child(connector);
	
	call_deferred(&"update_connectors");
	return connector;


func add_child_connector() -> TechTreeEditorConnector:
	
	var connector : TechTreeEditorConnector;
	if(ConnectorFile.can_instantiate() and ChildConnectorContainer):
		connector = ConnectorFile.instantiate();
		connector.setup(TechTreeEditorConnector.ConnectorType.Child, data.index, self);
		connector.connect_with.connect(connect_with);
		connector.disconnect_from.connect(disconnect_from);
		
		ChildConnectorContainer.add_child(connector);
	
	call_deferred(&"update_connectors");
	
	return connector;
	

func is_connected_to(other_node_id : int, type : TechTreeEditorConnector.ConnectorType) -> bool:
	var container : Control;
	match(type):
		TechTreeEditorConnector.ConnectorType.Parent:
			container = ParentConnectorContainer;
		TechTreeEditorConnector.ConnectorType.Child:
			container = ChildConnectorContainer;
	
	var connector : TechTreeEditorConnector;
	if(container):
		for item in container.get_children():
			if(item.connected_to):
				if(item.connected_to.parent_id == other_node_id):
					return true;
	
	return false;
	

func get_open_connector(type : TechTreeEditorConnector.ConnectorType) -> TechTreeEditorConnector:
	var container : Control;
	match(type):
		TechTreeEditorConnector.ConnectorType.Parent:
			container = ParentConnectorContainer;
		TechTreeEditorConnector.ConnectorType.Child:
			container = ChildConnectorContainer;
	
	var connector : TechTreeEditorConnector;
	if(container):
		for item in container.get_children():
			if(!item.connected_to):
				connector = item;
				break;
		
		# If no connectors, create one
		if(!connector):
			match(type):
				TechTreeEditorConnector.ConnectorType.Parent:
					connector = add_parent_connector();
				TechTreeEditorConnector.ConnectorType.Child:
					connector = add_child_connector();
	
	return connector;

func connect_to(other_node : TechTreeNodeEditor, type : TechTreeEditorConnector.ConnectorType) -> void:
	
	var connector : TechTreeEditorConnector = get_open_connector(type);
	
	# Get other connector of different type
	var other_connector : TechTreeEditorConnector = other_node.get_open_connector((type + 1) % 
		TechTreeEditorConnector.ConnectorType.size());
	
	if(connector and other_connector):
		connect_with(connector, other_connector);


func connect_with(base: TechTreeEditorConnector, other : TechTreeEditorConnector) -> void:
	base.connected_to = other;
	other.connected_to = base;
	
	var other_node : TechTreeNodeEditor = other.owner_node;
	
	if(base.Type == TechTreeEditorConnector.ConnectorType.Parent):
		if(!other_node.data.next_nodes.has(data.index)):
			other_node.data.next_nodes.append(data.index);
		if(!data.parent_nodes.has(other_node.data.index)):
			data.parent_nodes.append(other_node.data.index);
	else:
		if(!other_node.data.parent_nodes.has(data.index)):
			other_node.data.parent_nodes.append(data.index);
		if(!data.next_nodes.has(other_node.data.index)):
			data.next_nodes.append(other_node.data.index);
	
	connections_changed.emit(self, data.parent_nodes, data.next_nodes);
	other_node.connections_changed.emit(other_node, other_node.data.parent_nodes, other_node.data.next_nodes);

func disconnect_from(base: TechTreeEditorConnector, other : TechTreeEditorConnector) -> void:
	base.connected_to = null;
	other.connected_to = null;
	
	var other_node : TechTreeNodeEditor = other.owner_node;
	
	if(base.Type == TechTreeEditorConnector.ConnectorType.Parent):
		other_node.data.next_nodes.erase(data.index);
		data.parent_nodes.erase(other_node.data.index);
	else:
		other_node.data.parent_nodes.erase(data.index);
		data.next_nodes.erase(other_node.data.index);
	
	connections_changed.emit(self, data.parent_nodes, data.next_nodes);
	other_node.connections_changed.emit(other_node, other_node.data.parent_nodes, other_node.data.next_nodes);


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
			
			data.tier_values.append(0);
			
			count += 1;
		
		var tier_cost_container_children : Array[Node] = TierCostContainer.get_children();
		while(tier_count < count):
			TierCostContainer.remove_child(tier_cost_container_children[count - 1]);
			tier_cost_container_children[count - 1].queue_free();
			
			data.tier_values.pop_back();
			
			count -= 1;
	
	data_changed.emit(data);



func tier_cost_changed(tier_index : int, cost : int) -> void:
	data.tier_values[tier_index] = cost;
	data_changed.emit(data);


func set_unlock_requirement(unlock_requirement : TechTreeNode.AvailabilityRequirement) -> void:
	data.availability = unlock_requirement;
	
	if(unlock_requirement == TechTreeNode.AvailabilityRequirement.TreeProgress):
		if(ProgressRequirementContainer):
			ProgressRequirementContainer.visible = true;
	elif(ProgressRequirementContainer):
		ProgressRequirementContainer.visible = false;
	
	
	if(ProgressRequirementBox):
		data.availability_min = ProgressRequirementBox.value;
	
	data_changed.emit(data);



func set_progress_requirement(amount : int) -> void:
	data.availability_min = amount;
	data_changed.emit(data);

func description_changed(text : String) -> void:
	data.description = text;
	data_changed.emit(data);

func set_additional_data(value : int) -> void:
	if(AdditionalDataContainer):
		var count : int = AdditionalDataContainer.get_child_count();
		while(value > count):
			var additional_data : RootTechTreeEditorAdditionalDataSettings = AdditionalDataControlFile.instantiate();
			AdditionalDataContainer.add_child(additional_data);
			
			additional_data.data_changed.connect(additional_data_changed);
			
			count += 1;
		
		var data_container_children : Array[Node] = AdditionalDataContainer.get_children();
		while(value < count):
			AdditionalDataContainer.remove_child(data_container_children[count - 1]);
			data_container_children[count - 1].queue_free();
			
			count -= 1;
	
	data_changed.emit(data);


func additional_data_changed(additional_data : Dictionary) -> void:
	data.additional_data = get_additional_data();
	data_changed.emit(data);


func get_additional_data() -> Dictionary:
	
	var additional_data : Dictionary = {};
	
	var data_container_children : Array[Node] = AdditionalDataContainer.get_children();
	for additional_data_editor in data_container_children:
		var data_dict : Dictionary = additional_data_editor.get_data();
		
		additional_data[data_dict["name"]] = data_dict["data"];
	
	return additional_data;