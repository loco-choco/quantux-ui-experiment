extends Node2D

@export var enemy_scene : PackedScene
# --- Dependencies & Variables ---
@onready var enemy_cpt = 2
@onready var score := 0
@onready var nb_loots := 0
@export var possible_loots : Array[ItemData]

const nb_bullets = 6
@onready var current_bullet = 1

const item_blueprint = preload("res://scenes/item.tscn")

@onready var start_screen = $HUD/StartScreen
@onready var name_input = $HUD/StartScreen/CenterContainer/VBoxContainer/NameInput
@onready var game_over_screen = $HUD/GameOverScreen
@onready var final_score_label = $HUD/GameOverScreen/CenterContainer/VBoxContainer/FinalScoreLabel
@onready var health_bar = $HUD/HealthBar
@onready var score_label = $HUD/Score

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

func just_pressed_any(primary : bool):
	var which
	if primary:
		which = $Player.item_color
		can_big_shot = false
	else:
		if not $Player.second_weapon_color:
			return
		which = $Player.second_weapon_color
	$BigShot.start()
	get_node("Bullets/" + str(current_bullet)).shoot($Player.global_position, get_global_mouse_position(), which)
	current_bullet += 1
	if current_bullet > 6:
		current_bullet = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if get_tree().paused:
		return
	if not Input.is_action_pressed("shoot"):
		$BigShot.stop()
		create_tween().tween_property($Player, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if  InputMode.get_mode() == InputMode.Modes.PLAYER:
		if Input.is_action_just_pressed("shoot") and not Input.is_action_pressed("hud_toggle_quick_inv"):
			just_pressed_any(true)
		if Input.is_action_just_released("shoot") and can_big_shot:
			create_tween().tween_property($Player, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			get_node("Bullets/" + str(current_bullet)).shoot($Player.global_position, get_global_mouse_position(), $Player.item_color, true)
			current_bullet += 1
			$BigShot.stop()
			can_big_shot = false
			if current_bullet > 6:
				current_bullet = 1
		if Input.is_action_just_pressed("shoot_secondary") and not Input.is_action_pressed("hud_toggle_quick_inv"):
			just_pressed_any(false)
		for ch in $Loot.get_children():
			ch.visible = true

func _on_weapon_slot_update(weapon_data: ItemData) -> void:
	if has_node("Player"):
		$Player.set_weapon_color(weapon_data)

func _player_has_weapon_color(color: String) -> bool:
	if not has_node("HUD/Inventory"):
		return false
	var inventory = $HUD/Inventory
	
	var color_pattern = {
		'r': "red_gun",
		'g': "green_gun",
		'b': "blue_gun"
	}
	
	var pattern = color_pattern.get(color, "")
	if pattern == "":
		return false
	
	var weapon_item = inventory.weapon_slot.get_item()
	if weapon_item and weapon_item.data.texture:
		if pattern in weapon_item.data.texture.resource_path:
			return true
	var side_weapon_item = inventory.side_weapon_slot.get_item()
	if side_weapon_item and side_weapon_item.data.texture:
		if pattern in side_weapon_item.data.texture.resource_path:
			return true
	var bagged_items = inventory.get_bagged_items()
	for item_data in bagged_items:
		if item_data and item_data.texture and pattern in item_data.texture.resource_path:
			return true
	
	return false

func DropNewLoot(whom : Node2D, forced_index : int) -> Node2D:
	var clr_dice: int
	if forced_index != -1:
		clr_dice = forced_index
	else:
		clr_dice = randi() % 3
	var weapon_clr : String = ['r', 'g', 'b'][clr_dice]
	
	if _player_has_weapon_color(weapon_clr):
		return

	var itemData = ItemData.new()
	itemData.dimensions = Vector2i(1, 1)
	itemData.texture = load([	"res://assets/items/red_gun.png",\
								"res://assets/items/green_gun.png",\
								"res://assets/items/blue_gun.png"][clr_dice])

	var loot = item_blueprint.instantiate()
	loot.item_data = itemData
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
	score_label.text = "Score : " + str(score)
	score_label.scale = Vector2(1.5, 1.5)
	create_tween().tween_property(score_label, "scale", Vector2.ONE, 0.7).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	nb_loots += 1
	$Loot.add_child(DropNewLoot(whom, (whom.force_color_index+1)%3))

func _on_spawn_new_enemy_timeout() -> void:
	if get_tree().paused:
		return
	var new_enemy = enemy_scene.instantiate()
	new_enemy.name = "Enemy" + str(enemy_cpt)
	if enemy_cpt < 5:
		new_enemy.force_color_index = 0 # Red
	elif enemy_cpt < 10:
		new_enemy.force_color_index = 1 # Green
	elif enemy_cpt < 15:
		new_enemy.force_color_index = 2 # Blue
	else:
		new_enemy.force_color_index = -1 # Random
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
	if has_node("HUD/Inventory"):
		var inventory = $HUD/Inventory
		#LogInventory.start_logging(player_name, inventory)
	score = 0
	score_label.text = "Score : 0"
	start_screen.visible = false
	get_tree().paused = false
	$SpawnNewEnemy.start()

func game_over() -> void:
	get_tree().paused = true
	LogInput.stop_logging(str(score))
	#LogInventory.stop_logging()
	game_over_screen.visible = true
	final_score_label.text = "Final Score: [" + name_input.text + "] " + str(score)

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _add_starting_weapon() -> void:
	if not has_node("HUD/Inventory"):
		return
	var inventory = $HUD/Inventory
	var itemData = ItemData.new()
	itemData.dimensions = Vector2i(1, 1)
	itemData.name = "Red Gun"
	itemData.texture = load("res://assets/items/red_gun.png")
	var inventory_item = inventory.inventory_item_scene.instantiate()
	inventory_item.data = itemData
	inventory.inventory_item_parent.add_child(inventory_item)
	inventory.weapon_slot.set_item(inventory_item)
