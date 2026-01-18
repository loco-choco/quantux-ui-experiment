class_name InventoryItemOptionsPopup extends PanelContainer

@onready var options_list: VBoxContainer = $%OptionsList
@export var item_option_scene : PackedScene

var item: InventoryItem = null

func show_options(rec: Rect2, item_: InventoryItem) -> void:
	_set_item(item_)
	var pos: Vector2 = rec.position + Vector2(rec.size.x, 0)
	if not get_viewport_rect().encloses(Rect2(pos, size)):
		pos = rec.position - Vector2(size.x, 0)
	global_position = pos
	show()
	(options_list.get_child(0) as Control).grab_focus()

func _set_item(item_: InventoryItem) -> void:
	if self.item != item_:
		for c in options_list.get_children():
			c.queue_free()
	self.item = item_
	for option : String in item.data.options:
		var item_option : InventoryItemOption = item_option_scene.instantiate()
		item_option.option_data = option
		item_option.lost_focus.connect(_on_option_lost_focus)
		item_option.option_selected.connect(_on_option_selected)
		options_list.add_child(item_option)

func _on_option_selected(_option_data: String) -> void:
	hide()
	
func _on_option_lost_focus() -> void:
	for c : Control in options_list.get_children():
		if c.has_focus():
			return
	hide()
