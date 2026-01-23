class_name RoundData extends Resource

enum InventoryEvent {OPEN, CLOSE}

@export var inventory_events : Dictionary[String, InventoryEvent] = {}
@export var bag_frames : Dictionary[String, BagFrame] = {}
@export var wave_frames : Dictionary[String, WaveFrame] = {}
@export var mouse_frames : Dictionary[String, Vector2] = {}


func save_zip_archive(file_name : String = "user://archive.zip") -> void:
	var zip : ZIPPacker = ZIPPacker.new()
	var error = zip.open(file_name, ZIPPacker.ZipAppend.APPEND_CREATE)
	if error != OK:
		push_error("Couldn't open path for saving ZIP archive (error code: %s)." % error_string(error))
		return
		
	save_csv_in_zip(zip, _csv_inventory_events(), "inventory.csv")
	save_csv_in_zip(zip, _csv_wave_frames(), "waves.csv")
	save_csv_in_zip(zip, _csv_mouse_frames(), "mouse.csv")
	save_csv_in_zip(zip, _csv_bag_frame_values(), "bag_values.csv")
	save_csv_in_zip(zip, _csv_bag_frame_items(), "bag_items.csv")

	zip.close()

func save_csv_in_zip(zip : ZIPPacker, content : String, file_name : String = "csv.csv") -> void:
	zip.start_file(file_name)
	zip.write_file(content.to_ascii_buffer())
	zip.close_file()

func _csv_inventory_events() -> String:
	var csv : String = ""
	csv = csv + _to_csv_line(["timestamp", "event"])
	for time : String in inventory_events:
		var inv_event : InventoryEvent = inventory_events[time]
		csv = csv + _to_csv_line([time, InventoryEvent.keys()[inv_event] as String])
	return csv

func _csv_wave_frames() -> String:
	var csv : String = ""
	csv = csv + _to_csv_line(["timestamp", "amount", "closest_distance"])
	for time : String in wave_frames:
		var wave : WaveFrame = wave_frames[time]
		csv = csv + _to_csv_line([time, "%d" % [wave.amount_of_enemies], "%.2f" % [wave.closest_distance_to_player]])
	return csv

func _csv_mouse_frames() -> String:
	var csv : String = ""
	csv = csv + _to_csv_line(["timestamp", "x", "y"])
	for time : String in mouse_frames:
		csv = csv + _to_csv_line([time, "%d" % [mouse_frames[time].x], "%d" % [mouse_frames[time].y]])
	return csv

func _csv_bag_frame_values() -> String:
	var csv : String = ""
	csv = csv + _to_csv_line(["timestamp", "value"])
	for time : String in bag_frames:
		var bag_frame : BagFrame = bag_frames[time]
		csv = csv + _to_csv_line([time, "%d" % [bag_frame.current_value]])
	return csv
func _csv_bag_frame_items() -> String:
	var csv : String = ""
	csv = csv + _to_csv_line(["timestamp", "x", "y", "item"])
	for time : String in bag_frames:
		var bag_frame : BagFrame = bag_frames[time]
		for pos : Vector2i in bag_frame.frame:
			var slot_frame : SlotFrame = bag_frame.frame[pos]
			csv = csv + _to_csv_line([time, "%d" % [pos.x], "%d" % [pos.y], slot_frame.item_name])
	return csv
func _to_csv_line(line: PackedStringArray, del : String = ",") -> String:
	return del.join(line) + "\n"
