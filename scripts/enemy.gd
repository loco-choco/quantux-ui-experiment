class_name Enemy extends Node2D

signal died(enemy: Enemy)
signal wrong_color

@onready var hitbox : Area2D = $%Hitbox

@export var target : Player

@export var follow_speed : float = 80
@export var color_code : String = 'r'
@export var hp : float = 100
@export var damage_per_hit : int = 10
var time_since_last_hit : float
@export var time_per_hit : float = 4

var color : Vector3

func _ready() -> void:
	color = {'r': Vector3(1., 0., 0.), 'g': Vector3(0., 1., 0.), 'b': Vector3(0., 0.5, 1.)}[color_code]
	$Sprite2D.material.set_shader_parameter("clr", color)
	time_since_last_hit = randf_range(0, time_per_hit) # Offset when spawning to differ from other enemies
	#$Sprite2D.material.set_shader_parameter("clr", Vector3(1., 0., 0.))

func _process(delta: float) -> void:
	if hp > 0 and is_instance_valid(target) and target.current_health > 0:
		look_at(target.global_position)
		var speed : Vector2 = follow_speed * (target.global_position - global_position).normalized()
		if hitbox.overlaps_area(target.hitbox):
			speed = Vector2.ZERO # We reached the player, we can stop moving
			if time_since_last_hit >= time_per_hit:
				target.take_damage(damage_per_hit)
				time_since_last_hit = 0
		global_position += speed * delta
	
	time_since_last_hit = time_since_last_hit + delta if time_since_last_hit < time_per_hit else time_since_last_hit
	# On death animation
	if scale.x < 0.00001:
		queue_free()

func spriteFlash(value : Vector3) -> void:
	$Sprite2D.material.set_shader_parameter("clr", value)

func trigger_death(killed_by_player: bool) -> void:
	create_tween().tween_property(self, "scale", Vector2(0., 0.), 0.8).set_trans(Tween.TRANS_BACK)
	if killed_by_player:
		$Label.visible = true
		$Label.global_position = global_position + Vector2(60, -30)
		$Label.set_rotation(-rotation)
		$Label.remove_theme_color_override("font_color")
		$Label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		create_tween().tween_property($Label, "global_position", $Label.global_position - Vector2(0., 50.), 0.5)
		create_tween().tween_property($Label, "theme_override_colors/font_color", Color(1., 1., 1., 0.), 0.5)

func take_damage(damage: float) -> void:
	if hp <= 0:
		return
	hp = hp - damage
	if hp <= 0:
		trigger_death(true)
		died.emit(self)
