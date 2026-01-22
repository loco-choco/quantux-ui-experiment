class_name Player extends Node2D

signal item_collected(item_data: Item)
signal player_died
signal health_changed(new_value)

@export var speed = 200
@export var max_health = 3
var current_health

var grabbable_items: Array[Item] = []
@export var dropped_item_offset_radius : float = 25

@export var item_color : String = 'b'
@export var second_weapon_color : String
var sprite_clr = Vector3(0, 0, 1)

func _ready() -> void:
	$SpriteBouncer2D.stop()
	current_health = max_health
	health_changed.emit(current_health)

func _process(delta: float) -> void:
	if InputMode.get_mode() != InputMode.Modes.PLAYER:
		return
	var slowed_delta = delta
	#if Input.is_action_just_pressed("hud_toggle_quick_inv"):
	#	$BulletTime.start()
	#if not Input.is_action_pressed("hud_toggle_quick_inv"):
	#	$BulletTime.stop()
	#slowed_delta *= max(0.01, 1. - $BulletTime.time_left / $BulletTime.wait_time)
	var velocity = Input.get_vector("player_move_x_neg", \
									"player_move_x_pos", \
									"player_move_y_neg", \
									"player_move_y_pos")
	
	global_position += velocity * slowed_delta * speed;
	
	if Input.is_action_just_pressed("pickup_item"):
		if grabbable_items.size() > 0:
			var item : Item = grabbable_items.pop_back()
			item.diselect()
			item_collected.emit(item)

func spriteParam(value, property = "clr") -> void:
	$SpriteBouncer2D.material.set_shader_parameter(property, value)

func get_weapon(weapon: ItemData) -> String:
	if not weapon:
		return 'b'
	var weapon_prop : WeaponItemProperty = weapon.get_property("weapon")
	return weapon_prop.color

func on_weapon_change(weapon: ItemData) -> void:
	item_color = get_weapon(weapon)
	var new_clr = {"r" : Vector3(1., 0., 0.), "g" : Vector3(0., 1., 0.), "b" : Vector3(0., 0.5, 1.)}[item_color]
	create_tween().tween_method(spriteParam, sprite_clr, new_clr, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	sprite_clr = new_clr


func on_side_weapon_change(weapon: ItemData):
	second_weapon_color = get_weapon(weapon)

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
