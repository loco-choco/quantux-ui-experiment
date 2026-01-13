extends PanelContainer

signal weapon_slot_update(item: InventoryItem)

@export var inventory_item_scene: PackedScene

@onready var bag_grid: ItemGrid = $%Bag
@onready var quick_inv_grid: ItemGrid = $%QuickInventory
@onready var weapon_slot: InventorySlot = $%WeaponSlot

func _ready() -> void:
	weapon_slot.item_slot_update.connect(_weapon_slot_update)

func _weapon_slot_update(item: InventoryItem) -> void:
	weapon_slot_update.emit(item)

func add_item(item_data: ItemData) -> bool:
	var inventory_item = inventory_item_scene.instantiate()
	inventory_item.data = item_data
	add_child(inventory_item)
	var success = bag_grid.attempt_to_add_item_data(inventory_item)
	if !success: 
		print("Item doesn't fit!")
		inventory_item.queue_free()
	return success
	
func get_bagged_items() -> Array[InventoryItem]:
	return bag_grid.get_items()
	
func get_quick_inv_items() -> Array[InventoryItem]:
	return quick_inv_grid.get_items()

func get_weapon() -> InventoryItem:
	return weapon_slot.get_item()
