class_name FilteredItemGrid extends ItemGrid

@export var filter_item_property : String

func _ready() -> void:
	create_slots()

func create_slots() -> void:
	super.create_slots()
	for fs : FilteredInventorySlot in get_children():
		fs.filter_item_property = filter_item_property
