extends Control

var num_lvls = 5

func _ready():
	create_level_buttons()

func create_level_buttons():
	var grid = $grid
	
	var my_font = load("res://Font/PWPerspective.ttf")
	var default_texture = load("res://Art/level-button/level-button.png")
#	var hover_texture = load("res://textures/button_hover.png")
	var pressed_texture = load("res://Art/level-button/level-button-clicked.png")
	var locked_texture = load("res://Art/level-button/locked-default.png")
	var locked_clicked_texture = load("res://Art/level-button/locked.png")
	
#	var font = DynamicFont.new()
#	font.font_data = my_font
#	font.size = 24
#
	for level in range(1, num_lvls + 41):
#		var button = Button.new()
		var button = TextureButton.new()
		
		# Assign the textures to the button
		if level <= Global.unlkd:
			button.texture_normal = default_texture
			button.texture_pressed = pressed_texture
		else:
			button.texture_normal = locked_texture
			button.texture_pressed = locked_clicked_texture
			
		button.expand = true
		button.stretch_mode = TextureButton.STRETCH_SCALE
		

		
		button.rect_min_size = Vector2(96, 96)

#		button.name = str(level)
#		button.text = str(level)
		button.connect("pressed", self, "_on_level_button_pressed", [level])
		
#		button.rect_min_size = Vector2(64, 64) 
		
#		button.add_font_override("font", font)
		
		# Check if the level is unlocked and set the font color
#		if level <= Global.unlkd:
#			button.add_color_override("font_color", Color(0, 1, 0))  # Green
#		else:
#			button.add_color_override("font_color", Color(1, 0, 0))  # Red
		
		grid.add_child(button)
		


func _on_level_button_pressed(lvl_num):
	# Checks if level is unlocked	
	if lvl_num <= Global.unlkd:
		
		# If unlocked level has been picked , set global variable and go to game
		Global.set_lvl(lvl_num)
		var next_scene = preload("res://Scenes/Menus/main.tscn")
		get_tree().change_scene_to(next_scene)
