extends Node

var file: FileAccess
var is_active: bool = false

func start_logging(player_name: String):
	var datetime := Time.get_datetime_string_from_system(true)
	datetime = datetime.replace(":", "-").replace(" ", "_")
	var safe_name = player_name.validate_filename()
	var filename := "user://input_log_%s_%s.txt" % [safe_name, datetime]
	file = FileAccess.open(filename, FileAccess.WRITE)
	if file:
		file.store_line("=== Input Recording Started for: %s ===" % player_name)
		is_active = true
		print("Logging started for: ", player_name)
	else:
		push_error("Failed to open input log file")

func stop_logging(score: String):
	if file:
		file.store_line("Final Score: [" + score + "]")
		file.store_line("=== Input Recording Ended ===")
		file.close()
		file = null
	is_active = false

func _input(event):
	if not is_active or not file:
		return

	var datetime := Time.get_datetime_string_from_system(true)

	if event is InputEventKey:
		if event.echo:
			return

		if event.pressed:
			file.store_line("[%s] KEY DOWN: %s (keycode=%d)" % [datetime, OS.get_keycode_string(event.keycode), event.keycode])
		else:
			file.store_line("[%s] KEY UP: %s" % [datetime, OS.get_keycode_string(event.keycode)])

	elif event is InputEventMouseButton:
		file.store_line("[%s] MOUSE BUTTON %s: button=%d pos=%s" % [datetime, "DOWN" if event.pressed else "UP", event.button_index, event.position])

	elif event is InputEventMouseMotion:
		file.store_line("[%s] MOUSE MOVE: pos=%s rel=%s" % [datetime, event.position, event.relative])

	if file: file.flush()

func _exit_tree():
	stop_logging("-")
