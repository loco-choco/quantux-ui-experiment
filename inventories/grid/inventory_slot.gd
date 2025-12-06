extends CenterContainer
class_name InventorySlot

@export var inventory_item_scene: PackedScene = preload("res://inventories/grid/inventory_item.tscn")

@export var item: InventoryItem

signal slot_input(which: InventorySlot)
signal slot_hovered(which: InventorySlot, is_hovering: bool)

func _ready() -> void:
	add_to_group("inventory_slots")

func _on_texture_button_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_select"):
		slot_input.emit(self)

func _on_texture_button_focus_entered() -> void:
	slot_hovered.emit(self, true)

func _on_texture_button_focus_exited() -> void:
	slot_hovered.emit(self, false)

func has_item() -> bool:
	return item != null

func release_item() -> InventoryItem:
	if not item:
		return null
	var item_to_release := item
	item = null
	return item_to_release

func aquire_item(new_item: InventoryItem) -> bool:
	if item or not new_item:
		return false
	item = new_item
	if item.get_parent():
		item.reparent(self)
	else:
		add_child(item)
	return true
