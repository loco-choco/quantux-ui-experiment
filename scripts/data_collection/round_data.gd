class_name RoundData extends Resource

enum InventoryEvent {OPEN, CLOSE}

@export var inventory_events : Dictionary[String, InventoryEvent] = {}
@export var bag_frames : Dictionary[String, BagFrame] = {}
@export var wave_frames : Dictionary[String, WaveFrame] = {}
@export var mouse_frames : Dictionary[String, Vector2] = {}
