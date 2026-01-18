class_name InventoryItem extends Node2D

@export var data: ItemData = null
var is_rotated: bool = false

@export var is_picked: bool = false
@export var picked_pos: Vector2i = Vector2i.ZERO

@onready var panel: PanelContainer = $%Item
@onready var icon: TextureRect = $%Icon

@onready var diselected: Control = $%Diselected
@onready var selected: Control = $%Selected
@onready var held: Control = $%Held

@onready var options: Control = $%Options
@onready var options_list: VBoxContainer = $%OptionsList
@export var item_option_scene : PackedScene

var dimensions: Vector2i:
	get():
		return Vector2i(data.dimensions.y, data.dimensions.x) if is_rotated \
			   else data.dimensions

func _ready() -> void:
	if data:
		icon.texture = data.texture
		for option : String in data.options:
			var item_option : InventoryItemOption = item_option_scene.instantiate()
			item_option.option_data = option
			item_option.lost_focus.connect(_on_option_lost_focus)
			item_option.option_selected.connect(_on_option_selected)
			options_list.add_child(item_option)

func get_picked_up(pos: Vector2i = Vector2i.ZERO) -> void:
	add_to_group("held_item")
	show_held()
	is_picked = true
	picked_pos = pos
	z_index = 10

func update_size(rect: Rect2) -> void:
	global_position = rect.position
	panel.size = rect.size
	
func get_placed(rect: Rect2) -> void:
	update_size(rect)
	remove_from_group("held_item")
	show_unfocus()
	is_picked = false
	picked_pos = Vector2.ZERO
	z_index = 0
	
func show_focus() -> void:
	held.hide()
	diselected.hide()
	selected.show()
	
func show_unfocus() -> void:
	held.hide()
	diselected.show()
	selected.hide()
	
func show_held() -> void:
	held.show()
	diselected.hide()
	selected.hide()
	
func do_rotation() -> void:
	is_rotated = !is_rotated
	picked_pos = Vector2i(picked_pos.y, picked_pos.x)
	
func show_options(rec: Rect2) -> void:
	var pos: Vector2 = rec.position + Vector2(rec.size.x, 0)
	if not get_viewport_rect().encloses(Rect2(pos, options.size)):
		pos = rec.position - Vector2(options.size.x, 0)
	options.global_position = pos
	options.show()
	(options_list.get_child(0) as Control).grab_focus()
	
func hide_options() -> void:
	options.hide()
	
func _on_option_selected(option_data: String) -> void:
	hide_options()
	
func _on_option_lost_focus() -> void:
	for c : Control in options_list.get_children():
		if c.has_focus():
			return
	hide_options()
