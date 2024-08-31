extends Node

# number of unlocked levels
var unlkd

# current level
var cur_lvl

func _ready() -> void:
	unlkd = 1
	cur_lvl = 1
	
func unlock() -> void:
	unlkd += 1
	
func next_lvl() -> void:
	cur_lvl += 1
	
func set_lvl(lvl : int) -> void:
	cur_lvl = lvl
