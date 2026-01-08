class_name InventorySlot extends PanelContainer

var item_in_slot: InventoryItem = null

@export var top_neighbor : InventorySlot = null
@export var bottom_neighbor : InventorySlot = null
@export var right_neighbor : InventorySlot = null
@export var left_neighbor : InventorySlot = null

@export var infinity_size : bool = false
@onready var focus_sqr : ColorRect = $ColorRect

func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER_SELF:
		grab_focus()
	elif what == NOTIFICATION_FOCUS_ENTER:
		#focus_sqr.show()
		if item_in_slot: 
			item_in_slot.show_focus()
		var held_item : InventoryItem = get_tree().get_first_node_in_group("held_item")
		if held_item != null:
			held_item.global_position = global_position
	elif what == NOTIFICATION_FOCUS_EXIT:
		#focus_sqr.hide()
		if item_in_slot: 
			item_in_slot.show_unfocus()
		
func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_select"):
		var held_item : InventoryItem = get_tree().get_first_node_in_group("held_item")
		if held_item == null && item_in_slot != null: # Getting item from slot
			item_in_slot.get_picked_up()
			clear_item()
		elif held_item != null:
			var held_item_size : Vector2 = Vector2(held_item.dimensions) \
								 if not infinity_size else Vector2.ONE
			if item_in_slot == null:  # Placing item in slot
				if set_item(held_item):
					var item_rect : Rect2 = Rect2(global_position, size * held_item_size)
					held_item.get_placed(item_rect)
			else: # Swaping item held for the one in slot
				var old_item : InventoryItem = item_in_slot
				clear_item()
				if set_item(held_item): #Swap!
					var item_rect : Rect2 = Rect2(global_position, size * held_item_size)
					held_item.get_placed(item_rect)
					old_item.get_picked_up()
				else: #Return old item
					set_item(old_item)
		## TODO Add feedback that the new item couldnt fit the slot
		## IDEA: Make the held item shake and play a negation sfx

func get_item() -> InventoryItem:
	return item_in_slot

func has_item() -> bool:
	return item_in_slot != null

func set_neighbors_as_next_on_focus() -> void:
	if top_neighbor:
		focus_neighbor_top    = top_neighbor.get_path()
	if focus_neighbor_bottom:
		focus_neighbor_bottom = bottom_neighbor.get_path()
	if focus_neighbor_right:
		focus_neighbor_right  = right_neighbor.get_path()
	if focus_neighbor_left:
		focus_neighbor_left   = left_neighbor.get_path()

func set_item(item: InventoryItem) -> bool:
	assert(item.dimensions.x > 0 and item.dimensions.y > 0, "Dimension is not positive! ")
	var slots_used : Array[InventorySlot] = []
	print("Dim: ", item.dimensions)
	var can_set : bool = _set_item_recursive(item, 0, 0, slots_used)
	print("Used: ", slots_used.size())
	if can_set:
		for s in slots_used:
			s.item_in_slot = item
			s.focus_sqr.color = Color.CRIMSON
	return can_set

func _set_item_recursive(item: InventoryItem, x: int, y: int, tested: Array[InventorySlot]) -> bool:
	tested.append(self)
	if item_in_slot != null:
		return false
	if infinity_size: ## If infinity size, stop there
		item_in_slot = item
		return true
	## Check neighbors
	## Top
	if y > 0:
		if not top_neighbor:
			return false
		if top_neighbor not in tested \
		   and !top_neighbor._set_item_recursive(item, x, y-1, tested):
			return false
	## Bottom
	if y < item.dimensions.y - 1:
		if not bottom_neighbor:
			return false
		if bottom_neighbor not in tested \
		   and !bottom_neighbor._set_item_recursive(item, x, y+1, tested):
			return false
	## Left
	if x > 0:
		if not left_neighbor:
			return false
		if left_neighbor not in tested \
		   and !left_neighbor._set_item_recursive(item, x-1, y, tested):
			return false
	## Right
	if x < item.dimensions.x - 1:
		if not right_neighbor:
			return false
		if right_neighbor not in tested \
		   and !right_neighbor._set_item_recursive(item, x+1, y, tested):
			return false
	return true

func clear_item() -> void:
	if item_in_slot == null:
		return
	_clear_item_recursive(item_in_slot)
	
func _clear_item_recursive(item: InventoryItem) -> void:
	if item_in_slot != item:
		return
	focus_sqr.color = Color.WHITE
	item_in_slot = null
	if top_neighbor != null:
		top_neighbor._clear_item_recursive(item)
	if bottom_neighbor != null:
		bottom_neighbor._clear_item_recursive(item)
	if right_neighbor != null:
		right_neighbor._clear_item_recursive(item)
	if left_neighbor != null:
		left_neighbor._clear_item_recursive(item)
