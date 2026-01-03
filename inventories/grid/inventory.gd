extends PanelContainer

@export var items: Array[ItemData] = []
@export var inventory_item_scene: PackedScene
@onready var item_grid: GridContainer = $Bag

func _ready() -> void:
	for i in items:
		add_item(i)

func add_item(item_data: ItemData) -> void:
	var inventory_item = inventory_item_scene.instantiate()
	inventory_item.data = item_data
	add_child(inventory_item)
	var success = item_grid.attempt_to_add_item_data(inventory_item)
