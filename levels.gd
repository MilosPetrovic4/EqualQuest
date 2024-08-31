extends Control

var num_lvls = 5

func _ready():
	create_level_buttons()

func create_level_buttons():
	var grid = $grid
	
	for level in range(1, num_lvls + 1):
		var button = Button.new()
		button.name = str(level)
		button.text = str(level)
		button.connect("pressed", self, "_on_level_button_pressed", [level])
		grid.add_child(button)

func _on_level_button_pressed(lvl_num):
	# Checks if level is unlocked	
	if lvl_num <= Global.unlkd:
		
		# If unlocked level has been picked , set global variable and go to game
		Global.set_lvl(lvl_num)
		var next_scene = preload("res://main.tscn")
		get_tree().change_scene_to(next_scene)
