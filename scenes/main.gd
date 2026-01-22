class_name Main extends Node2D

const ruid_size : int = 12
var random_user_id : String

@export var tutorial_world : PackedScene
@export var regular_world : PackedScene
var current_world : Node

var collect_data : bool

@onready var main_menu : CanvasLayer = $%MainMenu

@onready var round_sumary : CanvasLayer = $%RoundSumary
@onready var game_over : Label = $%GameOver
@onready var game_won : VBoxContainer = $%GameWon
@onready var score : Label = $%Score

func _ready() -> void:
	collect_data = false
	random_user_id = generate_ruid()
	round_sumary.hide()
	InputMode.change_mode(InputMode.Modes.MENU)

func generate_ruid() -> String:
	var ruid : String = ""
	for i in range(ruid_size):
		ruid = ruid + char(randi_range(ord('a'), ord('z')))
	return ruid

func go_to_round_world(world : PackedScene) -> void:
	main_menu.hide()
	current_world = world.instantiate()
	get_tree().root.add_child(current_world)
	(current_world.find_child("RoundLogic") as RoundLogic).round_over.connect(_on_world_finish)

func _on_world_finish(points: int) -> void:
	return_from_world(points)
	current_world.queue_free()

func return_from_world(points: int) -> void:	
	round_sumary.show()
	if points >= 0:
		game_over.hide()
		game_won.show()
		score.text = "{0}".format([points])
	else:
		game_over.show()
		game_won.hide()

func _on_enable_data_collection_toggled(toggled_on: bool) -> void:
	collect_data = toggled_on
	if not collect_data:
		pass #TODO DELETE ALL CURRENT COLECTED DATA


func _on_start_game_pressed() -> void:
	go_to_round_world(regular_world)

func _on_return_pressed() -> void:
	main_menu.show()
	round_sumary.hide()
