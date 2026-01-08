class_name InventorySlot extends PanelContainer

var item_in_slot: InventoryItem = null

@export var top_neighbor : InventorySlot = null
@export var bottom_neighbor : InventorySlot = null
@export var right_neighbor : InventorySlot = null
@export var left_neighbor : InventorySlot = null

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_select"):
		var held_item : InventoryItem = get_tree().get_first_node_in_group("held_item")
		if held_item == null && item_in_slot != null: # Getting item from slot
			item_in_slot.get_picked_up()
			clear_item()
		elif held_item != null && item_in_slot == null:  # Placing item in slot
			if set_item(held_item):
				item_in_slot.get_placed(held_item.global_position)
		elif held_item != null && item_in_slot != null: # Swaping item held for the one in slot
			var old_item : InventoryItem = item_in_slot
			clear_item()
			if set_item(held_item): #Swap!
				item_in_slot.get_placed(held_item.global_position)
				old_item.get_picked_up()
			else: #Return old item
				set_item(old_item)
		## TODO Add feedback that the new item couldnt fit the slot
		## IDEA: Make the held item shake and play a negation sfx

func get_item() -> InventoryItem:
	return item_in_slot

func has_item() -> bool:
	return item_in_slot != null

func set_item(item: InventoryItem) -> bool:
	assert(item.dimensions.x <= 0 || item.dimensions.y <= 0, "Dimension is not positive! ")
	return _set_item_recursive_right(item, item.dimensions.x - 1, item.dimensions.y - 1)

func _set_item_recursive_right(item: InventoryItem, row: int, colums: int) -> bool:
	if item_in_slot != null:
		return false
	## Check neighbor to the right
	if row > 0:
		if right_neighbor == null:
			return false
		var can_set : bool = right_neighbor._set_item_recursive_right(item, row - 1, colums)
		if !can_set:
			return false
	## Check neighbor under
	if colums > 0:
		if bottom_neighbor == null:
			return false
		var can_set : bool = bottom_neighbor._set_item_recursive_down(item, colums - 1)
		if !can_set:
			return false
	item_in_slot = item
	return true
	
func _set_item_recursive_down(item: InventoryItem, column: int) -> bool:
	## Check neighbor under
	if item_in_slot != null:
		return false
	if column > 0:
		if bottom_neighbor == null:
			return false
		var can_set : bool = bottom_neighbor._set_item_recursive_down(item, column - 1)
		if !can_set:
			return false
	item_in_slot = item
	return true

func clear_item() -> void:
	if item_in_slot == null:
		return
	_clear_item_recursive(item_in_slot)
	
func _clear_item_recursive(item: InventoryItem) -> void:
	if item_in_slot != item:
		return
	item_in_slot = null
	if top_neighbor != null:
		top_neighbor._clear_item_recursive(item)
	if bottom_neighbor != null:
		bottom_neighbor._clear_item_recursive(item)
	if right_neighbor != null:
		right_neighbor._clear_item_recursive(item)
	if left_neighbor != null:
		left_neighbor._clear_item_recursive(item)
