extends Node2D

@export var enemy_scene : PackedScene
# --- Dependencies & Variables ---
@onready var enemy_cpt = 2
@onready var score := 0
@onready var nb_loots := 0

const nb_bullets = 6
@onready var current_bullet = 1

const item_blueprint = preload("res://scenes/item.tscn")

@onready var start_screen = $CanvasLayer/StartScreen
@onready var name_input = $CanvasLayer/StartScreen/CenterContainer/VBoxContainer/NameInput
@onready var game_over_screen = $CanvasLayer/GameOverScreen
@onready var final_score_label = $CanvasLayer/GameOverScreen/CenterContainer/VBoxContainer/FinalScoreLabel
@onready var health_bar = $CanvasLayer/HealthBar

@onready var curr_wrong_color = 1
@onready var can_big_shot := false

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if get_tree().paused:
		return

	if Input.is_action_just_pressed("shoot") and not $HUD/Inventory.visible:
		$BigShot.start()
		get_node("Bullets/" + str(current_bullet)).shoot($Player.global_position, get_global_mouse_position(), $Player.item_color)
		current_bullet += 1
		if current_bullet > 6:
			current_bullet = 1
		can_big_shot = false
	if Input.is_action_just_released("shoot") and not $HUD/Inventory.visible and can_big_shot:
		create_tween().tween_property($Player, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		get_node("Bullets/" + str(current_bullet)).shoot($Player.global_position, get_global_mouse_position(), $Player.item_color, true)
		current_bullet += 1
		$BigShot.stop()
		can_big_shot = false
		if current_bullet > 6:
			current_bullet = 1
	for ch in $Loot.get_children():
		ch.visible = true

func DropNewLoot(whom : Node2D) -> Node2D:
	var clr_dice = randi() % 3	
	var weapon_clr : String = ['r', 'g', 'b'][clr_dice]

	var itemData = ItemData.new()
	itemData.dimensions = Vector2i(1, 1)
	itemData.texture = load([	"res://assets/items/red_gun.png",\
								"res://assets/items/green_gun.png",\
								"res://assets/items/blue_gun.png"][clr_dice])

	var loot = item_blueprint.instantiate()
	loot.item_data = itemData
	loot.name = weapon_clr + str(nb_loots)
	loot.global_position = whom.global_position

	return loot
	
func wrong_color_popup(where : Vector2):
	var new_label = Label.new()
	new_label.text = "Wrong color !"
	new_label.name = str(curr_wrong_color)
	new_label.visible = true
	new_label.global_position = where
	new_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	create_tween().tween_property(new_label, "global_position", new_label.global_position - Vector2(0., 50.), 0.5)
	create_tween().tween_property(new_label, "theme_override_colors/font_color", Color(1., 1., 1., 0.), 0.5)
	
	$HUD/WrongColorLabels.add_child(new_label)
	curr_wrong_color += 1

func killed_enemy(whom : Node2D):
	score += 1000
	$Score.text = "Score : " + str(score)
	$Score.scale = Vector2(1.5, 1.5)
	create_tween().tween_property($Score, "scale", Vector2.ONE, 0.7).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	nb_loots += 1
	$Loot.add_child(DropNewLoot(whom))

func _on_spawn_new_enemy_timeout() -> void:
	if get_tree().paused:
		return
	var new_enemy = enemy_scene.instantiate()
	new_enemy.name = "Enemy" + str(enemy_cpt)
	enemy_cpt += 1
	var where_to_spawn = [Vector2(randi_range(0, 1000), -60), Vector2(randi_range(0, 1000), 600), Vector2(-60, randi_range(0, 600)), Vector2(1030, randi_range(0, 600))]
	new_enemy.global_position = where_to_spawn[randi() % 4]
	add_child(new_enemy)

func _on_big_shot_timeout() -> void:
	create_tween().tween_property($Player, "scale", Vector2(1.6, 1.6), 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	can_big_shot = true

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
	LogInput.stop_logging(str(score))
	game_over_screen.visible = true
	final_score_label.text = "Final Score: [" + name_input.text + "] " + str(score)

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
