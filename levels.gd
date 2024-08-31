extends Control

var num_lvls = 5

func _ready():
	create_level_buttons()

func create_level_buttons():
	var grid = $grid
	
	for level in num_lvls:
		var button = Button.new()
		button.name = str(level)
		button.text = str(level)
		button.connect("pressed", self, "_on_level_button_pressed", [level])
		grid.add_child(button)

func _on_level_button_pressed(level_num):
	get_tree().get_root().set_meta("cur_lvl", level_num)
	var next_scene = preload("res://main.tscn")
	get_tree().change_scene_to(next_scene)
