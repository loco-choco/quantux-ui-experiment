class_name EnemyWaveLogic extends Node2D

signal wave_completed(wave: int)

@export var enemy_scene : PackedScene

@export var enemy_waves : Array[EnemyWave]
@export var current_wave : int = 0

@export var player : Player
@export var spawn_radius : float

var current_alive_enemies : Array[Enemy]
func _ready() -> void:
	spawn_wave()

func spawn_wave() -> void:
	if current_wave >= enemy_waves.size():
		return
	var wave : EnemyWave = enemy_waves[current_wave]
	for i in range(wave.amount_of_enemies):
		var enemy : Enemy = enemy_scene.instantiate()
		var pos : Vector2 = Vector2.from_angle(randf_range(0, TAU)) * spawn_radius
		add_child(enemy)
		enemy.global_position = pos + player.global_position
		enemy.target = player
		enemy.color_code = wave.possible_spawns[randi_range(0,wave.possible_spawns.size() - 1)]
		current_alive_enemies.append(enemy)
		enemy.died.connect(_on_enemy_died)

func _on_enemy_died(enemy: Enemy) -> void:
	current_alive_enemies.erase(enemy)
	if current_alive_enemies.size() <= 0:
		print("Wave ", current_wave, " completed!")
		wave_completed.emit(current_wave)
		current_wave = current_wave + 1
