extends Node2D

# --- Dependencies & Variables ---
const enemy_scene = preload("res://gameplay/enemy.tscn")
@onready var enemy_cpt = 2
@onready var score := 0

const nb_bullets = 6
@onready var current_bullet = 1

@onready var start_screen = $CanvasLayer/StartScreen
@onready var name_input = $CanvasLayer/StartScreen/CenterContainer/VBoxContainer/NameInput
@onready var game_over_screen = $CanvasLayer/GameOverScreen
@onready var final_score_label = $CanvasLayer/GameOverScreen/CenterContainer/VBoxContainer/FinalScoreLabel
@onready var health_bar = $CanvasLayer/HealthBar

func _ready() -> void:
	start_screen.visible = true
	game_over_screen.visible = false
	get_tree().paused = true
	$SpawnNewEnemy.stop()
	
	if has_node("Player"):
		var player = $Player
		health_bar.max_value = player.max_health
		health_bar.value = player.max_health
		if not player.health_changed.is_connected(_on_player_health_changed):
			player.health_changed.connect(_on_player_health_changed)
			
		if not player.player_died.is_connected(game_over):
			player.player_died.connect(game_over)

func _on_player_health_changed(new_value: int) -> void:
	health_bar.value = new_value

func _process(delta: float) -> void:
	if get_tree().paused:
		return

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
	if get_tree().paused:
		return

	var new_enemy = enemy_scene.instantiate()
	new_enemy.name = "Enemy" + str(enemy_cpt)
	enemy_cpt += 1
	var where_to_spawn = [Vector2(randi_range(0, 1000), -60), Vector2(randi_range(0, 1000), 600), Vector2(-60, randi_range(0, 600)), Vector2(1030, randi_range(0, 600))]
	new_enemy.global_position = where_to_spawn[randi() % 4]
	add_child(new_enemy)

func _on_start_button_pressed() -> void:
	var player_name = name_input.text
	if player_name.strip_edges() == "":
		print("Please enter a name!")
		return 
	LogInput.start_logging(player_name)
	score = 0
	$Score.text = "Score : 0"
	start_screen.visible = false
	get_tree().paused = false
	$SpawnNewEnemy.start()

func game_over() -> void:
	get_tree().paused = true
	LogInput.stop_logging()
	game_over_screen.visible = true
	final_score_label.text = "Final Score: " + str(score)

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
