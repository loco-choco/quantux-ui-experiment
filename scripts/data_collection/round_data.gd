class_name RoundData extends Resource

enum InventoryEvent {OPEN, CLOSE}

var inventory_events : Dictionary[String, InventoryEvent] = {}
var bag_frames : Dictionary[String, BagFrame] = {}
var wave_frames : Dictionary[String, WaveFrame] = {}
var mouse_frames : Dictionary[String, Vector2] = {}
