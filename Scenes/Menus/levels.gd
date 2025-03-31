extends Control

var num_lvls = 5

func _ready():
	create_level_buttons()

func create_level_buttons():
	var grid = $grid
	
	var my_font = load("res://Font/PWPerspective.ttf")
	
	var font = DynamicFont.new()
	font.font_data = my_font
	font.size = 24
	
	for level in range(1, num_lvls + 46): #(1, num_lvls + 1)
		var button = Button.new()
		button.name = str(level)
		button.text = str(level)
		button.connect("pressed", self, "_on_level_button_pressed", [level])
		
		button.rect_min_size = Vector2(90, 90) 
		
		button.add_font_override("font", font)
		
		# Check if the level is unlocked and set the font color
		if level <= Global.unlkd:
			button.add_color_override("font_color", Color(0, 1, 0))  # Green
		else:
			button.add_color_override("font_color", Color(1, 0, 0))  # Red
		
		grid.add_child(button)

func _on_level_button_pressed(lvl_num):
	# Checks if level is unlocked	
	if lvl_num <= Global.unlkd:
		
		# If unlocked level has been picked , set global variable and go to game
		Global.set_lvl(lvl_num)
		var next_scene = preload("res://Scenes/Menus/main.tscn")
		get_tree().change_scene_to(next_scene)
