class_name RadialInventoryEntry extends AspectRatioContainer

@export var item : InventoryItem

@onready var icon : TextureRect = $%Icon

func _ready() -> void:
	if item:
		icon.texture = item.data.texture
