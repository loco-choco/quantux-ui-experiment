extends Node2D

@export var enemy_scene : PackedScene
@onready var enemy_cpt = 2
@onready var score := 0

const nb_bullets = 6
@onready var current_bullet = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		get_node("Bullets/" + str(current_bullet)).shoot($Player.global_position, get_global_mouse_position())
		current_bullet += 1
		if current_bullet > 6:
			current_bullet = 1

func killed_enemy():
	score += 1000
	$Score.text = "Score : " + str(score)
	$Score.scale = Vector2(1.5, 1.5)
	create_tween().tween_property($Score, "scale", Vector2.ONE, 0.7).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _on_spawn_new_enemy_timeout() -> void:
	return
	var new_enemy = enemy_scene.instantiate()
	new_enemy.name = "Enemy" + str(enemy_cpt)
	enemy_cpt += 1
	var where_to_spawn = [Vector2(randi_range(0, 1000), -60), Vector2(randi_range(0, 1000), 600), Vector2(-60, randi_range(0, 600)), Vector2(1030, randi_range(0, 600))]
	new_enemy.global_position = where_to_spawn[randi() % 4]
	add_child(new_enemy)
