extends Node

var is_active: bool = false
var inventory_ref: Inventory = null

func start_logging(player_name: String, inventory: Inventory):
	is_active = true
	inventory_ref = inventory
	print("Inventory logging started for: ", player_name)
	log_inventory_state("INITIAL_STATE")

func stop_logging():
	if is_active:
		log_inventory_state("FINAL_STATE")
	is_active = false
	inventory_ref = null

func log_inventory_state(action: String):
	if not is_active or not inventory_ref or not LogInput.is_active or not LogInput.file:
		return

	var datetime := Time.get_datetime_string_from_system(true)
	var file = LogInput.file
	file.store_line("")
	file.store_line("[%s] INVENTORY ACTION: %s" % [datetime, action])
	file.store_line("--- Inventory State Changed ---")
	
	# Log weapon slot
	var weapon = inventory_ref.get_weapon()
	if weapon:
		file.store_line("  WEAPON_SLOT: %s (dim: %s)" % [weapon.name, weapon.dimensions])
	else:
		file.store_line("  WEAPON_SLOT: empty")
	
	# Log shield slot
	var shield_item = inventory_ref.shield_slot.get_item()
	if shield_item:
		file.store_line("  SHIELD_SLOT: %s (dim: %s)" % [shield_item.data.name, shield_item.data.dimensions])
	else:
		file.store_line("  SHIELD_SLOT: empty")
	
	# Log side weapon slot
	var side_weapon_item = inventory_ref.side_weapon_slot.get_item()
	if side_weapon_item:
		file.store_line("  SIDE_WEAPON_SLOT: %s (dim: %s)" % [side_weapon_item.data.name, side_weapon_item.data.dimensions])
	else:
		file.store_line("  SIDE_WEAPON_SLOT: empty")
	
	# Log bag items as a grid
	var bag_grid = inventory_ref.bag_grid
	var rows = bag_grid.rows
	var cols = bag_grid.columns
	var slots = bag_grid.get_children()
	
	# Create item to ID mapping
	var item_to_id = {}
	var next_id = 1
	var grid = []
	
	for y in range(rows):
		var row = []
		for x in range(cols):
			var slot_index = x + y * cols
			var slot = slots[slot_index]
			var item = slot.get_item()
			
			if item:
				if item not in item_to_id:
					item_to_id[item] = next_id
					next_id += 1
				row.append(item_to_id[item])
			else:
				row.append(0)
		grid.append(row)
	
	file.store_line("  BAG_GRID (%dx%d):" % [cols, rows])
	file.store_line("    " + str(grid))
	
	# Log item ID mapping
	if item_to_id.size() > 0:
		file.store_line("  BAG_ITEMS_MAP:")
		for item in item_to_id:
			file.store_line("    [%d] %s (dim: %s)" % [item_to_id[item], item.data.name, item.data.dimensions])
	
	# Log quick inventory items as a grid
	var quick_inv_grid = inventory_ref.quick_inv_grid
	var quick_rows = quick_inv_grid.rows
	var quick_cols = quick_inv_grid.columns
	var quick_slots = quick_inv_grid.get_children()
	
	# Create item to ID mapping for quick inventory
	var quick_item_to_id = {}
	var quick_next_id = 1
	var quick_grid = []
	
	for y in range(quick_rows):
		var row = []
		for x in range(quick_cols):
			var slot_index = x + y * quick_cols
			var slot = quick_slots[slot_index]
			var item = slot.get_item()
			
			if item:
				if item not in quick_item_to_id:
					quick_item_to_id[item] = quick_next_id
					quick_next_id += 1
				row.append(quick_item_to_id[item])
			else:
				row.append(0)
		quick_grid.append(row)
	
	file.store_line("  QUICK_INVENTORY_GRID (%dx%d):" % [quick_cols, quick_rows])
	file.store_line("    " + str(quick_grid))
	
	# Log item ID mapping for quick inventory
	if quick_item_to_id.size() > 0:
		file.store_line("  QUICK_ITEMS_MAP:")
		for item in quick_item_to_id:
			file.store_line("    [%d] %s (dim: %s)" % [quick_item_to_id[item], item.data.name, item.data.dimensions])
	
	file.store_line("--- End State ---")
	
	if file:
		file.flush()

func _exit_tree():
	stop_logging()
