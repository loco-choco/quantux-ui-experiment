extends Control

const inventory_item_scene = preload("res://inventories/grid/inventory_slot.tscn")
#const inventory_item = preload("res://inventories/grid/inventory_item.tscn")

@export var rows: int = 3
@export var columns: int = 3

var slots: Array[InventorySlot]

var selected_item: Item = null
var original_owner: InventorySlot = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(columns * rows):
		var slot : InventorySlot = inventory_item_scene.instantiate()
		slots.append(slot)
		$CenterContainer/GridContainer.add_child(slot)
		$CenterContainer/GridContainer.columns = columns
		slot.slot_input.connect(_on_slot_input)

func _on_slot_input(which: InventorySlot) -> void:
	if not selected_item and which.has_item():
		selected_item = which.release_item()
		original_owner = which
	elif selected_item:
		if which != original_owner:
			original_owner.aquire_item(which.release_item())
		which.aquire_item(selected_item)
		selected_item = null
		original_owner = null

func add_item(item: Item) -> bool:
	for slot in slots:
		if not slot.has_item():
			item.hide_in_game()
			slot.aquire_item(item)
			return true
	return false
