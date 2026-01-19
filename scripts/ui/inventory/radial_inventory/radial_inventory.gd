class_name RadialInventory extends PanelContainer

signal menu_closed()

@export var radial_inv_entry : PackedScene

@onready var entries : Container = $%Entries

var last_entry : RadialInventoryEntry = null

func _process(_delta: float) -> void:
	var selection_vec: Vector2 = (get_local_mouse_position() - size/2 ).normalized()
	if selection_vec.is_zero_approx():
		return
	var selection: int = floori(rad_to_deg(selection_vec.angle() + PI) / 360 \
						 * entries.get_child_count()) % entries.get_child_count()
	var entry_selected : RadialInventoryEntry = entries.get_child(selection) as RadialInventoryEntry
	if last_entry != entry_selected:
		if last_entry:
			last_entry.show_diselected()
		entry_selected.show_selected()
		last_entry = entry_selected
	
	if Input.is_action_just_pressed("inventory_select"):
		print("Selected: ", selection)
		menu_closed.emit()

func update_radial_inventory(items: Array[InventoryItem]) -> void:
	clean_entries()
	create_entries(items)

func clean_entries() -> void:
	last_entry = null
	for c in entries.get_children():
		c.queue_free()

func create_entries(items: Array[InventoryItem]) -> void:
	for item in items:
		var entry : RadialInventoryEntry = radial_inv_entry.instantiate()
		entry.item = item
		entries.add_child(entry)
