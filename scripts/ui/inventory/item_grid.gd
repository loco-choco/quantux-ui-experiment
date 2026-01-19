class_name ItemGrid extends MatrixContainer

@export var inventory_slot_scene: PackedScene

signal item_slot_popup(slot: InventorySlot, item: InventoryItem)
signal items_update(items: Array[InventoryItem])

func _ready() -> void:
	create_slots()

func create_slots() -> void:
	var slots: Array[InventorySlot] = []
	for y in rows:
		for x in columns:
			var inventory_slot : InventorySlot = inventory_slot_scene.instantiate()
			add_child(inventory_slot)
			inventory_slot.item_slot_popup.connect(_on_item_slot_popup)
			inventory_slot.item_slot_update.connect(_on_item_slot_update)
			slots.push_back(inventory_slot)
	for y in rows:
		for x in columns:
			var slot : InventorySlot = slots[x + y * columns]
			slot.top_neighbor    = slots[x + (y - 1) * columns] if y > 0           else null
			slot.bottom_neighbor = slots[x + (y + 1) * columns] if y < rows - 1    else null
			slot.right_neighbor  = slots[x + 1 + y * columns]   if x < columns - 1 else null
			slot.left_neighbor   = slots[x - 1 + y * columns]   if x > 0           else null
			slot.set_neighbors_as_next_on_focus()

func attempt_to_add_item_data(item: InventoryItem) -> bool:
	if _attempt_to_add_item_data(item):
		return true
	## Try with rotated item
	item.do_rotation()
	if _attempt_to_add_item_data(item):
		return true
	return false

func _attempt_to_add_item_data(item: InventoryItem) -> bool:
	for s : InventorySlot in get_children():
			if s.set_item(item):
				var item_rect : Rect2 = Rect2(s.global_position, \
											  s.size * Vector2(item.dimensions))
				item.get_placed(item_rect)
				return true
	return false


func get_items() -> Array[InventoryItem]:
	var items: Array[InventoryItem] = []
	for s : InventorySlot in get_children():
		if s.get_item() and not items.has(s.get_item()):
			items.append(s.get_item())
	return items

func _on_item_slot_popup(slot: InventorySlot, item: InventoryItem) -> void:
	item_slot_popup.emit(slot, item)
	
func _on_item_slot_update(item: InventoryItem) -> void:
	items_update.emit(get_items())
