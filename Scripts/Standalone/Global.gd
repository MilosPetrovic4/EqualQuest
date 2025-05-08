extends Node

# number of unlocked levels
var unlkd
var selected
var audio_state

# current level
var cur_lvl
var lvl_one_tut

const num_lvls = 46

func _ready() -> void:
	unlkd = 1
	cur_lvl = 1
	audio_state = 1
	selected = false
	lvl_one_tut = true
	
func lvv_one_tut_finished():
	lvl_one_tut = false
	
func unlock() -> void:
	unlkd += 50
	
func next_lvl() -> void:
	cur_lvl += 1
	
func set_lvl(lvl : int) -> void:
	cur_lvl = lvl
