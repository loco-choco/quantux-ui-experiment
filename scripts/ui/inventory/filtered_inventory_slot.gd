class_name FilteredInventorySlot extends InventorySlot

@onready var refuse : Control = $%Refused

@export var filter_item_property : String

func allowed_item(item: InventoryItem) -> bool:
	return item.data.get_property(filter_item_property) != null

func _can_have_item(item: InventoryItem) -> bool:
	return super._can_have_item(item) and allowed_item(item) 

func _process(_delta: float) -> void:
	super._process(_delta)
	var held_item : InventoryItem = get_tree().get_first_node_in_group("held_item")
	if held_item and not allowed_item(held_item):
		refuse.show()
	else: 
		refuse.hide()
