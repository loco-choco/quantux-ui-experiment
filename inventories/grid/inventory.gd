class_name Inventory extends PanelContainer

signal weapon_slot_update(item: ItemData)
signal item_dropped(item: Item)

@export var inventory_item_scene: PackedScene
@export var item_scene: PackedScene

@onready var bag_grid: ItemGrid = $%Bag
@onready var quick_inv_grid: ItemGrid = $%QuickInventory
@onready var weapon_slot: InventorySlot = $%WeaponSlot
@onready var drop_item_slot: InventorySlot = $%DropItemSlot

func _ready() -> void:
	weapon_slot.item_slot_update.connect(_weapon_slot_update)
	drop_item_slot.item_slot_update.connect(_drop_item_slot_update)

func drop_held_item() -> void:
	var held_item : InventoryItem = get_tree().get_first_node_in_group("held_item")
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
	var dropped_item : Item  = item_scene.instantiate()
	dropped_item.item_data = inv_item.data
	inv_item.queue_free()
	drop_item_slot.clear_item()
	item_dropped.emit(dropped_item)

func add_item(item: Item) -> bool:
	var item_data : ItemData = item.item_data
	var inventory_item : InventoryItem  = inventory_item_scene.instantiate()
	inventory_item.data = item_data
	add_child(inventory_item)
	var success = bag_grid.attempt_to_add_item_data(inventory_item)
	if !success: 
		print("Item doesn't fit!")
		inventory_item.queue_free()
		item_dropped.emit(item)
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
