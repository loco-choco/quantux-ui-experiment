class_name RoundLogic extends Node

signal round_over(points: int)

@export var player : Player
@export var hud : PlayerHUD
@export var wave_logic : EnemyWaveLogic

func _ready() -> void:
	player.player_died.connect(on_game_over)
	wave_logic.last_wave_completed.connect(on_game_won)
func on_game_over() -> void:
	_round_end_logic()
	print("Game over!")
	round_over.emit(-1)
	
func on_game_won() -> void:
	_round_end_logic()
	var total_value : int = 0
	for item : InventoryItem in hud.inventory.get_bagged_items():
		var valuable : ValuableItemProperty = item.data.get_property("valuable")
		if valuable:
			total_value = total_value + valuable.value
	print("Game won with ", total_value, " points!")
	round_over.emit(total_value)

func _round_end_logic() -> void:
	InputMode.change_mode(InputMode.Modes.MENU)
