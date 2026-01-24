class_name Enemy extends Node2D

signal died(enemy: Enemy)

@onready var hitbox : Area2D = $%Hitbox
@onready var score : Label = $%Score
var score_local_position : Vector2
@onready var wrong_color : Label = $%WrongColor
var wrong_color_local_position : Vector2

@export var target : Player

@export var follow_speed : float = 400
@export var approach_speed : float = 350
@export var approach_distance : float = 700
@export var color_code : String = 'r'
@export var wrong_color_demage_penalty : float = 0.1
@export var hp : float = 100
@export var damage_per_hit : int = 10
var time_since_last_hit : float
@export var time_per_hit : float = 4

var color : Vector3

func _ready() -> void:
	score_local_position = score.position
	wrong_color_local_position = wrong_color.position
	color = {'r': Vector3(1., 0., 0.), 'g': Vector3(0., 1., 0.), 'b': Vector3(0., 0.5, 1.)}[color_code]
	$Sprite2D.material.set_shader_parameter("clr", color)
	time_since_last_hit = randf_range(0, time_per_hit) # Offset when spawning to differ from other enemies
	#$Sprite2D.material.set_shader_parameter("clr", Vector3(1., 0., 0.))

func _process(delta: float) -> void:
	if hp > 0 and is_instance_valid(target) and target.current_health > 0:
		look_at(target.global_position)
		var distance_sqr : float = (target.global_position - global_position).length_squared()
		var speed : float = follow_speed if distance_sqr > approach_distance * approach_distance \
							else approach_speed
		if hitbox.overlaps_area(target.hitbox):
			speed = 0 # We reached the player, we can stop moving
			if time_since_last_hit >= time_per_hit:
				target.take_damage(damage_per_hit)
				time_since_last_hit = 0
		global_position += speed * delta * (target.global_position - global_position).normalized()
	
	time_since_last_hit = time_since_last_hit + delta if time_since_last_hit < time_per_hit else time_since_last_hit
	# On death animation
	if scale.x < 0.00001:
		queue_free()

func spriteFlash(value : Vector3) -> void:
	$Sprite2D.material.set_shader_parameter("clr", value)

func trigger_death(killed_by_player: bool) -> void:
	create_tween().tween_property(self, "scale", Vector2(0., 0.), 0.8).set_trans(Tween.TRANS_BACK)
	if killed_by_player:
		score.show()
		score.global_position = global_position + score_local_position
		score.set_rotation(-rotation)
		score.remove_theme_color_override("font_color")
		score.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		create_tween().tween_property(score, "global_position", score.global_position - Vector2(0., 50.), 0.5)
		create_tween().tween_property(score, "theme_override_colors/font_color", Color(1., 1., 1., 0.), 0.5)

func take_damage(damage: float, bullet_color: String) -> void:
	if bullet_color != color_code:
		damage = damage * wrong_color_demage_penalty
		_on_wrong_color()
	if hp <= 0:
		return
	hp = hp - damage
	if hp <= 0:
		trigger_death(true)
		died.emit(self)

func _on_wrong_color() -> void:
	wrong_color.show()
	wrong_color.global_position = global_position + wrong_color_local_position
	wrong_color.set_rotation(-rotation)
	wrong_color.remove_theme_color_override("font_color")
	wrong_color.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	create_tween().tween_property(wrong_color, "theme_override_colors/font_color", Color(1., 1., 1., 0.), 0.5)
