class_name RoundData extends Resource

enum InventoryEvent {OPEN, CLOSE}

@export var inventory_events : Dictionary[String, InventoryEvent] = {}
@export var bag_frames : Dictionary[String, BagFrame] = {}
@export var weapon_slot_frames : Dictionary[String, SlotFrame] = {}
@export var side_weapon_slot_frames : Dictionary[String, SlotFrame] = {}
@export var wave_frames : Dictionary[String, WaveFrame] = {}
@export var mouse_frames : Dictionary[String, Vector2] = {}


func save_to_zip_archive(zip : ZIPPacker, file_prefix : String = "") -> void:	
	save_csv_in_zip(zip, _csv_inventory_events(), file_prefix + "inventory.csv")
	save_csv_in_zip(zip, _csv_wave_frames(), file_prefix + "waves.csv")
	save_csv_in_zip(zip, _csv_mouse_frames(), file_prefix + "mouse.csv")
	save_csv_in_zip(zip, _csv_bag_frame_values(), file_prefix + "bag_values.csv")
	save_csv_in_zip(zip, _csv_bag_frame_items(), file_prefix + "bag_items.csv")
	save_csv_in_zip(zip, _csv_slot_items(weapon_slot_frames), file_prefix + "weapon_slot.csv")
	save_csv_in_zip(zip, _csv_slot_items(side_weapon_slot_frames), file_prefix + "side_weapon.csv")

func save_csv_in_zip(zip : ZIPPacker, content : String, file_name : String = "csv.csv") -> void:
	zip.start_file(file_name)
	zip.write_file(content.to_ascii_buffer())
	zip.close_file()
	
func _to_csv_line(line: PackedStringArray, del : String = ",") -> String:
	return del.join(line) + "\n"

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

func _csv_slot_items(dict : Dictionary[String, SlotFrame]) -> String:
	var csv : String = ""
	csv = csv + _to_csv_line(["timestamp", "item"])
	for time : String in dict:
		var slot_frame : SlotFrame = dict[time]
		csv = csv + _to_csv_line([time, slot_frame.item_name])
	return csv
