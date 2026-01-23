class_name Main extends Node2D

const ruid_size : int = 12
var random_user_id : String

@export var tutorial_world : PackedScene
@export var regular_world : PackedScene
var current_world : RoundWorld

var collect_data : bool
var collected_round_data : Array[RoundData] = []

@onready var main_menu : Control = $%MainMenu
@onready var pre_game_questionnaire : PreGameQuestionnaire = $%PreGameQuestionnaire

@onready var tutorial : Control = $%Tutorial
@onready var round_sumary : Control = $%RoundSumary
@onready var game_over : Label = $%GameOver
@onready var game_won : VBoxContainer = $%GameWon
@onready var score : Label = $%Score

func _ready() -> void:
	collect_data = false
	random_user_id = generate_ruid()
	main_menu.show()
	tutorial.hide()
	round_sumary.hide()
	pre_game_questionnaire.hide()
	pre_game_questionnaire.finished_questionnaire.connect(_on_finished_pregame_quest)
	InputMode.change_mode(InputMode.Modes.MENU)

func generate_ruid() -> String:
	var ruid : String = ""
	for i in range(ruid_size):
		ruid = ruid + char(randi_range(ord('a'), ord('z')))
	return ruid

func go_to_round_world(world : PackedScene) -> void:
	main_menu.hide()
	current_world = world.instantiate() as RoundWorld
	get_tree().root.add_child(current_world)
	current_world.round_logic.round_over.connect(_on_world_finish)

func _on_start_pregame_quest() -> void:
	main_menu.hide()
	pre_game_questionnaire.show()
	
func _on_finished_pregame_quest() -> void:
	main_menu.show()
	pre_game_questionnaire.hide()

func _on_world_finish(points: int) -> void:
	get_tree().paused = true
	return_from_world(points)

func return_from_world(points: int) -> void:
	if collect_data:
		collected_round_data.append(current_world.round_data_collection.round_data)
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
		collected_round_data.clear()

func _on_start_game_pressed() -> void:
	get_tree().paused = false
	go_to_round_world(regular_world)

func _on_round_summary_return_pressed() -> void:
	main_menu.show()
	round_sumary.hide()
	current_world.queue_free()
	
func _on_tutorial_pressed() -> void:
	main_menu.hide()
	tutorial.show()

func _on_tutorial_return_pressed() -> void:
	main_menu.show()
	tutorial.hide()

func _on_export_data_pressed() -> void:
	_export_data_as_zip()

func _export_data_as_zip() -> void:
	var file_name : String = "user://%s.zip" % [random_user_id]
	var zip : ZIPPacker = ZIPPacker.new()
	var error = zip.open(file_name, ZIPPacker.ZipAppend.APPEND_CREATE)
	if error != OK:
		push_error("Couldn't open path for saving ZIP archive (error code: %s)." % error_string(error))
		return
	## Saving RUID
	save_ruid_to_zip_archive(zip, "ruid.txt")
	## Saving questionnaires
	pre_game_questionnaire.questionnaire_data.save_json_in_zip(zip, "pre_game_quest.json")
	## Saving round data
	for i : int in range(collected_round_data.size()):
		collected_round_data[i].save_to_zip_archive(zip, "round_%d/" % [i])
	
	zip.close()
	
func save_ruid_to_zip_archive(zip : ZIPPacker, file_name : String) -> void:
	zip.start_file(file_name)
	zip.write_file(("%s\n" % [random_user_id]).to_ascii_buffer())
	zip.close_file()
