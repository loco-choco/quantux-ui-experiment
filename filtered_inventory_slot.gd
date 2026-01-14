class_name FilteredInventorySlot extends InventorySlot

@onready var refuse : Control = $%Refused

@export var filter_tag : String

func _can_have_item(item: InventoryItem) -> bool:
	return item.data.tags.has(filter_tag)

func _process(_delta: float) -> void:
	var held_item : InventoryItem = get_tree().get_first_node_in_group("held_item")
	if held_item and not _can_have_item(held_item):
		refuse.show()
	else: 
		refuse.hide()
