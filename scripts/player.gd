class_name Player extends Node2D

signal item_collected(item_data: Item)
signal player_died
signal health_changed(new_value)

@export var speed = 200
@export var max_health = 3
@onready var current_health = max_health

@onready var inventory : Inventory = $%Inventory
var grabbable_items: Array[Item] = []
@export var dropped_item_offset_radius : float = 25

func _ready() -> void:
	$SpriteBouncer2D.stop()
	current_health = max_health
	health_changed.emit(current_health)

func _process(delta: float) -> void:
	if InputMode.get_mode() != InputMode.Modes.PLAYER:
		return
	var velocity = Input.get_vector("player_move_x_neg", \
									"player_move_x_pos", \
									"player_move_y_neg", \
									"player_move_y_pos")
	
	global_position += velocity * delta * speed;
	
	if Input.is_action_just_pressed("pickup_item"):
		if grabbable_items.size() > 0:
			var item : Item = grabbable_items.pop_back()
			item.diselect()
			item_collected.emit(item)

func _on_interactable_enter(area: Area2D) -> void:
	var item_coll : ItemInteractCollider = area as ItemInteractCollider
	var item : Item = item_coll.get_item() if item_coll else null
	if item and not grabbable_items.has(item):
		if grabbable_items.size() > 0:
			grabbable_items[-1].diselect()
		grabbable_items.push_back(item)
		item.select()
		
func _on_interactable_exit(area: Area2D) -> void:
	var item_coll : ItemInteractCollider = area as ItemInteractCollider
	var item : Item = item_coll.get_item() if item_coll else null
	if item:
		grabbable_items.erase(item)
		item.diselect()
		if grabbable_items.size() > 0:
			grabbable_items[-1].select()

func _on_inventory_item_dropped(item: Item) -> void:
	item.global_position = global_position + \
			Vector2.RIGHT.rotated(randf()*2*PI) * dropped_item_offset_radius
	if item.get_parent() != get_parent():
		get_parent().add_child(item)
	grabbable_items.push_front(item)
	grabbable_items[-1].select()

func _on_inventory_item_returned(item: Item) -> void:
	grabbable_items.push_front(item)
	grabbable_items[-1].select()

func take_damage(amount: int) -> void:
	current_health -= amount
	health_changed.emit(current_health)
	print("Player took damage! Health is now: ", current_health)
	var tween = create_tween()
	tween.set_parallel(true) 
	modulate = Color(1, 0, 0)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	scale = Vector2(0.8, 0.8)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	var shake_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
	global_position += shake_offset
	
	if current_health <= 0:
		die()

func die() -> void:
	player_died.emit()
	queue_free()
