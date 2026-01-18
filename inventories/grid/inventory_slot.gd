class_name InventorySlot extends PanelContainer

signal item_slot_update(item: InventoryItem)
signal item_slot_popup(slot: InventorySlot, item: InventoryItem)

@export var top_neighbor : InventorySlot = null
@export var bottom_neighbor : InventorySlot = null
@export var right_neighbor : InventorySlot = null
@export var left_neighbor : InventorySlot = null

@export var infinity_size : bool = false
@onready var selected : Control = $%Selected
@onready var available : Control = $%Available

var item_in_slot: InventoryItem = null
var item_slot_pos: Vector2i = Vector2i()

func _process(_delta: float) -> void:
	var held_item : InventoryItem = get_tree().get_first_node_in_group("held_item")
	if held_item and _can_have_item(held_item):
		available.show()
	else: 
		available.hide()
		
func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER_SELF:
		grab_focus()
	elif what == NOTIFICATION_FOCUS_ENTER:
		selected.show()
		if item_in_slot: 
			item_in_slot.show_focus()
		var held_item : InventoryItem = get_tree().get_first_node_in_group("held_item")
		if held_item != null:
			held_item.update_size(item_rect(held_item))
	elif what == NOTIFICATION_FOCUS_EXIT:
		selected.hide()
		if item_in_slot:
			item_in_slot.show_unfocus()
	elif what == NOTIFICATION_RESIZED:
		if item_in_slot and item_slot_pos == Vector2i.ZERO: 
			item_in_slot.update_size(item_rect(item_in_slot))

func item_rect(item: InventoryItem) -> Rect2:
	var pos : Vector2 = Vector2.ZERO if infinity_size \
				else size * Vector2(item.picked_pos)
	var dim : Vector2 = Vector2.ONE if infinity_size else Vector2(item.dimensions)
	var rect : Rect2 = Rect2(global_position - pos, size * dim)
	return rect

func _gui_input(event: InputEvent) -> void:
	var held_item : InventoryItem = get_tree().get_first_node_in_group("held_item")
	if event.is_action_pressed("inventory_rotate"):
		if held_item:
			held_item.do_rotation()
			held_item.update_size(item_rect(held_item))
			
	if event.is_action_pressed("item_use"):
		if held_item == null && item_in_slot != null: # Can only use when no item held
			item_slot_popup.emit(self, item_in_slot)
		
	if event.is_action_pressed("inventory_select"):
		if held_item == null && item_in_slot != null: # Getting item from slot
			item_in_slot.get_picked_up(item_slot_pos)
			clear_item()
		elif held_item != null:
			var intersecting_items: Dictionary[InventoryItem, InventorySlot] \
				= find_intersecting_items(held_item.dimensions, held_item.picked_pos)
			if intersecting_items.size() == 0: # No items in region, we can place
				if set_item(held_item, held_item.picked_pos):
					held_item.get_placed(item_rect(held_item))
					held_item.show_focus()
			elif intersecting_items.size() == 1: 
			# Swaping item held for the one in the region
				var interc_item : InventoryItem = intersecting_items.keys()[0]
				var interc_item_slot: InventorySlot = intersecting_items[interc_item]
				var interc_item_slot_pos : Vector2i = interc_item_slot.item_slot_pos
				interc_item_slot.clear_item()
				if set_item(held_item, held_item.picked_pos): #Swap!
					held_item.get_placed(item_rect(held_item))
					held_item.show_focus() 
					interc_item.get_picked_up(interc_item_slot_pos)
					interc_item.update_size(item_rect(interc_item))
				else: #Return old item
					interc_item_slot.set_item(interc_item, interc_item_slot_pos)
		## TODO Add feedback that the new item couldnt fit the slot
		## IDEA: Make the held item shake and play a negation sfx
func get_item() -> InventoryItem:
	return item_in_slot

func has_item() -> bool:
	return item_in_slot != null

func _can_have_item(_item: InventoryItem) -> bool:
	return not has_item()

func set_neighbors_as_next_on_focus() -> void:
	if top_neighbor:
		focus_neighbor_top    = top_neighbor.get_path()
	if focus_neighbor_bottom:
		focus_neighbor_bottom = bottom_neighbor.get_path()
	if focus_neighbor_right:
		focus_neighbor_right  = right_neighbor.get_path()
	if focus_neighbor_left:
		focus_neighbor_left   = left_neighbor.get_path()

func set_item(item: InventoryItem, pos: Vector2i = Vector2.ZERO) -> bool:
	assert(item.dimensions.x > 0 and item.dimensions.y > 0, "Dimension is not positive!")
	assert(pos.x >= 0 and pos.x < item.dimensions.x \
	   and pos.y >= 0 and pos.y < item.dimensions.y, "Slot position outside item dimension!")
	var slots_used : Dictionary[InventorySlot, Vector2i] = {}
	#print("Dim: ", item.dimensions)
	var can_set : bool = _set_item_recursive(item, pos.x, pos.y, slots_used)
	#print("Used: ", slots_used.size())
	if can_set:
		for s in slots_used:
			s.item_in_slot = item
			s.item_slot_pos = slots_used[s]
		item_slot_update.emit(item)
	return can_set

func _set_item_recursive(item: InventoryItem, x: int, y: int, tested: Dictionary[InventorySlot, Vector2i]) -> bool:
	tested[self] = Vector2i(x, y)
	if not _can_have_item(item):
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
	item_slot_update.emit(null)
	
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

func find_intersecting_items(dimension: Vector2i, pos: Vector2i = Vector2i.ZERO) -> Dictionary[InventoryItem, InventorySlot]:
	assert(dimension.x > 0 and dimension.y > 0, "Dimension is not positive!")
	assert(pos.x >= 0 and pos.x < dimension.x \
	   and pos.y >= 0 and pos.y < dimension.y, "Slot position outside item dimension!")
	var slots_in_region : Array[InventorySlot] = []
	#print("Intr Dim: ", dimension)
	#print("Intr Pos: ", pos)
	_find_intersecting_items_recursive(dimension, pos.x, pos.y, slots_in_region)
	var slots_with_unique_items : Dictionary[InventoryItem, InventorySlot] = {}
	for s in slots_in_region:
		if s.item_in_slot and s.item_in_slot not in slots_with_unique_items:
			slots_with_unique_items[s.item_in_slot] = s
	return slots_with_unique_items

func _find_intersecting_items_recursive(dimension: Vector2i, x: int, y: int, tested: Array[InventorySlot]) -> void:
	tested.append(self)
	## Check neighbors
	## Top
	if y > 0:
		if top_neighbor and top_neighbor not in tested:
			top_neighbor._find_intersecting_items_recursive(dimension, x, y-1, tested)
	## Bottom	
	if y < dimension.y - 1:
		if bottom_neighbor and bottom_neighbor not in tested:
			bottom_neighbor._find_intersecting_items_recursive(dimension, x, y+1, tested)
	## Left
	if x > 0:
		if left_neighbor and left_neighbor not in tested:
			left_neighbor._find_intersecting_items_recursive(dimension, x - 1, y, tested)
	## Right
	if x < dimension.x - 1:
		if right_neighbor and right_neighbor not in tested:
			right_neighbor._find_intersecting_items_recursive(dimension, x + 1, y, tested)
