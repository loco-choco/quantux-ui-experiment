extends CanvasLayer
@onready var inventory : Inventory = $%Inventory
func _ready() -> void:
	inventory.hide()
	InputMode.change_mode(InputMode.Modes.PLAYER)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hud_toggle_inventory"):
		if not inventory.visible: 
			inventory.show()
			inventory.set_focus()
			InputMode.change_mode(InputMode.Modes.UI)
		else:
			inventory.hide()
			inventory.drop_held_item()
			InputMode.change_mode(InputMode.Modes.PLAYER)

func _on_player_item_collected(item: Item) -> void:
	inventory.add_item(item)
