extends GridContainer

const inventory_item_scene = preload("res://inventories/grid/inventory_slot.tscn")
const inventory_item = preload("res://inventories/grid/inventory_item.tscn")

@export var rows: int = 3

var slots: Array[InventorySlot]

var selected_item: InventoryItem = null
var original_owner: InventorySlot = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(columns * rows):
		var slot : InventorySlot = inventory_item_scene.instantiate()
		slots.append(slot)
		add_child(slot)
		slot.slot_input.connect(_on_slot_input)
		slot.slot_hovered.connect(_on_slot_hovered)

func _on_slot_input(which: InventorySlot) -> void:
	if not selected_item and which.has_item():
		selected_item = which.release_item()
		original_owner = which
		print("Slot selected!")
	if selected_item and which != original_owner:
		original_owner.aquire_item(which.release_item())
		which.aquire_item(selected_item)
		selected_item = null
		original_owner = null
		print("Switched!")
	
func _on_slot_hovered(_which: InventorySlot, is_hovering: bool) -> void:
	if is_hovering:
		print("hovering slot :P")

func add_item(_item: Item) -> bool:
	for slot in slots:
		if not slot.has_item():
			print("adding to slot!")
			slot.aquire_item(inventory_item.instantiate())
			return true
	return false
