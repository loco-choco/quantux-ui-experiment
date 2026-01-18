class_name InventoryItemOptionsPopup extends PanelContainer

@onready var options_list: VBoxContainer = $%OptionsList
@export var item_option_scene : PackedScene

@export var item: InventoryItem = null
@export var slot_rec: Rect2 = Rect2()

func _ready() -> void:
	_set_item()
	_position_popup()

func _position_popup() -> void:
	var pos: Vector2 = slot_rec.position + Vector2(slot_rec.size.x, 0)
	if not get_viewport_rect().encloses(Rect2(pos, size)):
		pos = slot_rec.position - Vector2(size.x, 0)
	global_position = pos
	(options_list.get_child(0) as Control).grab_focus()

func _set_item() -> void:
	for option : String in item.data.options:
		var item_option : InventoryItemOption = item_option_scene.instantiate()
		item_option.option_data = option
		item_option.lost_focus.connect(_on_option_lost_focus)
		item_option.option_selected.connect(_on_option_selected)
		options_list.add_child(item_option)

func _on_option_selected(_option_data: String) -> void:
	queue_free()
	
func _on_option_lost_focus() -> void:
	for c : Control in options_list.get_children():
		if c.has_focus():
			return
	queue_free()
