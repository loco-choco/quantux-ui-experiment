class_name Item extends Area2D

@export var item_data: ItemData
@onready var icon: TextureRect = $%Icon
@onready var diselected: Control = $%Diselected
@onready var selected: Control = $%Selected

func _ready() -> void:
	sync_with_item_data()
	disselect()

func sync_with_item_data() -> void:
	icon.texture = item_data.texture

func disselect() -> void:
	diselected.show()
	selected.hide()
	
func select() -> void:
	diselected.hide()
	selected.show()
