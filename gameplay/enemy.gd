extends Node2D

var player
@export var follow_speed := 80.
@onready var hp := 3
signal died

func _ready() -> void:
	player = $"../Player"
	$Sprite2D.material.set_shader_parameter("clr", Vector3(1., 0., 0.))
	if get_parent().has_method("killed_enemy"):
		died.connect(get_parent().killed_enemy)

func _process(delta: float) -> void:
	if is_instance_valid(player) and hp > 0:
		look_at(player.global_position)
		global_position += follow_speed * (player.global_position - global_position).normalized() * delta
		
	if scale.x < 0.00001:
		queue_free()

func spriteFlash(value : Vector3) -> void:
	$Sprite2D.material.set_shader_parameter("clr", value)

func trigger_death(killed_by_player: bool) -> void:
	hp = 0
	create_tween().tween_property(self, "scale", Vector2(0., 0.), 0.8).set_trans(Tween.TRANS_BACK)
	if killed_by_player:
		$Label.visible = true
		$Label.global_position = global_position + Vector2(60, -30)
		$Label.set_rotation(-rotation)
		create_tween().tween_property($Label, "global_position", $Label.global_position - Vector2(0., 50.), 0.5)
		create_tween().tween_property($Label, "theme_override_colors/font_color", Color(1., 1., 1., 0.), 0.5)
		died.emit()

func _on_area_2d_area_entered(area: Area2D) -> void:
	var target = area
	if not target.has_method("take_damage") and target.get_parent().has_method("take_damage"):
		target = target.get_parent()
		
	if target.has_method("take_damage"):
		target.take_damage(1)
		trigger_death(false)
		return

	if not area.get_parent().visible: return

	var recoil_dir = Vector2.ZERO
	if is_instance_valid(player):
		recoil_dir = (player.global_position - global_position).normalized()
	
	var new_pos = global_position - 30. * recoil_dir
	
	create_tween().tween_property(self, "global_position", new_pos, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	create_tween().tween_method(spriteFlash, Vector3(1., 1., 1.), Vector3(1., 0., 0.), 0.32).set_trans(Tween.TRANS_QUAD)
	
	area.get_parent().visible = false
	
	hp -= 1
	if hp == 0:
		trigger_death(true)
