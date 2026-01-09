extends Node

var file: FileAccess

func _ready():
	var datetime := Time.get_datetime_string_from_system(true)
	
	datetime = datetime.replace(":", "-").replace(" ", "_")

	var filename := "user://input_log_%s.txt" % datetime
	file = FileAccess.open(filename, FileAccess.WRITE)

	if file:
		file.store_line("=== Input Recording Started ===")
	else:
		push_error("Failed to open input log file")

func _input(event):
	if not file:
		return

	var datetime := Time.get_datetime_string_from_system(true)

	if event is InputEventKey:
		# Ignore auto-repeat while holding key
		if event.echo:
			return

		if event.pressed:
			file.store_line(
				"[%s] KEY DOWN: %s (keycode=%d)" %
				[datetime, OS.get_keycode_string(event.keycode), event.keycode]
			)
		else:
			file.store_line(
				"[%s] KEY UP: %s" %
				[datetime, OS.get_keycode_string(event.keycode)]
			)

	elif event is InputEventMouseButton:
		file.store_line(
			"[%s] MOUSE BUTTON %s: button=%d pos=%s" %
			[
				datetime,
				"DOWN" if event.pressed else "UP",
				event.button_index,
				event.position
			]
		)

	elif event is InputEventMouseMotion:
		file.store_line(
			"[%s] MOUSE MOVE: pos=%s rel=%s" %
			[datetime, event.position, event.relative]
		)

	file.flush()

func _exit_tree():
	if file:
		file.store_line("=== Input Recording Ended ===")
		file.close()
