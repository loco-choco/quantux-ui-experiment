class_name RadialInventoryEntry extends Control

@export var item : InventoryItem

@onready var diselected: Control = $%Diselected
@onready var selected: Control = $%Selected
@onready var icon : TextureRect = $%Icon

func _ready() -> void:
	show_diselected()
	if item:
		icon.texture = item.data.texture

func show_selected() -> void:
	diselected.hide()
	selected.show()
	
func show_diselected() -> void:
	diselected.show()
	selected.hide()
