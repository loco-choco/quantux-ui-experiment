extends Node2D

@export var enemy_scene : PackedScene
@onready var enemy_cpt = 2
@onready var score := 0
@onready var nb_loots := 0

const nb_bullets = 6
@onready var current_bullet = 1

const item_blueprint = preload("res://scenes/item.tscn")

@onready var curr_wrong_color = 1
@onready var can_big_shot := false

func _process(_delta: float) -> void:
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
	var new_enemy = enemy_scene.instantiate()
	new_enemy.name = "Enemy" + str(enemy_cpt)
	enemy_cpt += 1
	var where_to_spawn = [Vector2(randi_range(0, 1000), -60), Vector2(randi_range(0, 1000), 600), Vector2(-60, randi_range(0, 600)), Vector2(1030, randi_range(0, 600))]
	new_enemy.global_position = where_to_spawn[randi() % 4]
	add_child(new_enemy)

func _on_big_shot_timeout() -> void:
	create_tween().tween_property($Player, "scale", Vector2(1.6, 1.6), 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	can_big_shot = true
