extends Area2D

signal item_collected(item_data: Item)
signal player_died
signal health_changed(new_value)

@export var speed = 200
@export var max_health = 10
@onready var current_health = max_health

func _ready() -> void:
	$SpriteBouncer2D.stop()
	current_health = max_health
	health_changed.emit(current_health)

func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("player_move_x_pos"): velocity.x += 1
	if Input.is_action_pressed("player_move_x_neg"): velocity.x -= 1
	if Input.is_action_pressed("player_move_y_pos"): velocity.y += 1
	if Input.is_action_pressed("player_move_y_neg"): velocity.y -= 1
	if velocity.length() > 0:
		global_position += velocity.normalized() * delta * speed

func _on_area_entered(area: Area2D) -> void:
	if area is Item:
		item_collected.emit(area as Item)

func take_damage(amount: int) -> void:
	current_health -= amount
	health_changed.emit(current_health)
	var tween = create_tween()
	tween.set_parallel(true) 
	modulate = Color(1, 0, 0)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	scale = Vector2(0.5, 0.5)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	var shake_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
	global_position += shake_offset
	
	if current_health <= 0:
		die()

func die() -> void:
	player_died.emit()
	queue_free()
