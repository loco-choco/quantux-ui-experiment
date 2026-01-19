extends Node

enum Modes {PLAYER, UI}

var mode : Modes = Modes.PLAYER

func change_mode(m: Modes) -> void:
	mode = m
	
func get_mode() -> Modes:
	return mode
