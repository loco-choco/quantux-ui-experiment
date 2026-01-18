class_name Inventory extends PanelContainer

signal weapon_slot_update(item: ItemData)
signal item_dropped(item: Item)
signal item_returned(item: Item)

@export var item_scene: PackedScene
@onready var inventory_item_parent: Control =$%InventoryItems
@export var inventory_item_scene: PackedScene
@onready var inventory_item_popup_parent: Control =$%InventoryItemsPopups
@export var inventory_item_popup_scene: PackedScene

@onready var bag_grid: ItemGrid = $%Bag
@onready var quick_inv_grid: ItemGrid = $%QuickInventory
@onready var shield_slot: InventorySlot = $%ShieldSlot
@onready var weapon_slot: InventorySlot = $%WeaponSlot
@onready var side_weapon_slot: InventorySlot = $%SideWeaponSlot
@onready var drop_item_slot: InventorySlot = $%DropItemSlot

func _ready() -> void:
	connect_item_slot_updates()
	connect_item_slot_popup()

func connect_item_slot_updates() -> void:
	weapon_slot.item_slot_update.connect(_weapon_slot_update)
	drop_item_slot.item_slot_update.connect(_drop_item_slot_update)
	
func connect_item_slot_popup() -> void:
	shield_slot.item_slot_popup.connect(create_item_popup)
	weapon_slot.item_slot_popup.connect(create_item_popup)
	side_weapon_slot.item_slot_popup.connect(create_item_popup)
	bag_grid.item_slot_popup.connect(create_item_popup)
	quick_inv_grid.item_slot_popup.connect(create_item_popup)

func handle_held_item() -> void:
	var held_item : InventoryItem = get_tree().get_first_node_in_group("held_item")
	if held_item:
		var success = bag_grid.attempt_to_add_item_data(held_item)
		if !success: 
			_drop_item_slot_update(held_item)

func set_focus() -> void:
	(bag_grid.get_child(0) as Control).grab_focus()


func _weapon_slot_update(item: InventoryItem) -> void:
	if item:
		weapon_slot_update.emit(item.data)
	else:
		weapon_slot_update.emit(null)
	
func _drop_item_slot_update(inv_item: InventoryItem) -> void:
	if inv_item == null:
		return
	drop_item_from_slot(inv_item, drop_item_slot)

func drop_item_from_slot(inv_item: InventoryItem, slot: InventorySlot) -> void:
	var dropped_item : Item  = item_scene.instantiate()
	dropped_item.item_data = inv_item.data
	inv_item.queue_free()
	slot.clear_item()
	item_dropped.emit(dropped_item)

func add_item(item: Item) -> bool:
	var item_data : ItemData = item.item_data
	var inventory_item : InventoryItem  = inventory_item_scene.instantiate()
	inventory_item.data = item_data
	inventory_item_parent.add_child(inventory_item)
	var success = bag_grid.attempt_to_add_item_data(inventory_item)
	if !success: 
		print("Item doesn't fit!")
		inventory_item.queue_free()
		item_returned.emit(item)
	else:
		item.queue_free()
	return success

func get_bagged_items() -> Array[ItemData]:
	var lambda = func (i: InventoryItem) -> ItemData:
		return i.data
	return bag_grid.get_items().map(lambda)
	
func get_quick_inv_items() -> Array[ItemData]:
	var lambda = func (i: InventoryItem) -> ItemData:
		return i.data
	return quick_inv_grid.get_items().map(lambda)

func get_weapon() -> ItemData:
	return weapon_slot.get_item().data

func create_item_popup(slot: InventorySlot, item: InventoryItem) -> void:
	var item_popup : InventoryItemOptionsPopup  = inventory_item_popup_scene.instantiate()
	item_popup.item = item
	item_popup.slot = slot
	item_popup.selected_option.connect(_on_item_popup_selected_option)
	inventory_item_popup_parent.add_child(item_popup)

func _on_item_popup_selected_option(slot: InventorySlot, item: InventoryItem,\
									option: ItemProperty) -> void:
	slot.grab_focus()
	option.use_property(self, slot, item)
