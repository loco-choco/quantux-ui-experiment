 extends CenterContainer
class_name InventorySlot

var item: Item

signal slot_input(which: InventorySlot)

func _ready() -> void:
	$ItemSprite.texture = null

func _on_texture_button_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_select"):
		slot_input.emit(self)

func has_item() -> bool:
	return item != null

func release_item() -> Item:
	if not item:
		return null
	var item_to_release := item
	item = null
	$ItemSprite.texture = null
	return item_to_release

func aquire_item(new_item:Item) -> bool:
	if item or not new_item:
		return false
	item = new_item
	$ItemSprite.texture = item.icon
	return true
