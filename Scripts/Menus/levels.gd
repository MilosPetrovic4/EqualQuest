extends Control

#var num_lvls = 30
var scroll_speed := Vector2(50, 0)
var buttons = []

#func resetTween(var tween):
#	if tween:
#		tween.kill()
#	tween = create_tween()

func _ready():
	create_level_buttons()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_esc_pressed()
		
func _on_esc_pressed():
	var scene = load("res://Scenes/Menus/Menu.tscn")
	get_tree().change_scene_to(scene)

func create_level_buttons():
	var grid = $grid
	var default_texture = load("res://Art/Buttons/Level-Button/level-button.png")
	var pressed_texture = load("res://Art/Buttons/Level-Button/level-button-clicked.png")
	var locked_texture = load("res://Art/Buttons/Level-Button/locked-default.png")
	var locked_clicked_texture = load("res://Art/Buttons/Level-Button/locked.png")
	
	var font = DynamicFont.new()
	font.font_data = load("res://Font/edit-undo/editundo.ttf")
	font.size = 48
	font.outline_size = 2
	font.outline_color = Color(0, 0, 0)

	for level in range(1, Global.num_lvls):
		var button = TextureButton.new()
		
		# Assign the textures to the button
		if level <= Global.unlkd:
			button.texture_normal = default_texture
			button.texture_pressed = pressed_texture
			button.rect_pivot_offset.x = 32
			button.rect_pivot_offset.y = 32
			
			button.set_script(load("res://Scripts/Buttons/level-button.gd"))
			
			
			# Create and configure the label
			var label = Label.new()
			label.text = str(level)
			label.align = Label.ALIGN_CENTER
			label.valign = Label.ALIGN_CENTER
			label.rect_size = Vector2(96, 96)
			label.rect_position = Vector2.ZERO
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # So the label doesn't block button clicks
			label.rect_position = Vector2(2, -5)

			label.add_font_override("font", font)
			button.add_child(label)
			
			# Store label reference for animation
			button.set_meta("label", label)

			# Connect press/release to animate label position
			button.connect("button_down", self, "_on_button_down", [button])
			button.connect("button_up", self, "_on_button_up", [button])
			
#			button.connect("mouse_entered", self, "_on_mouse_down", [button])
#			button.connect("mouse_exited", self, "_on_mouse_up", [button])
		else:
			button.texture_normal = locked_texture
			button.texture_pressed = locked_clicked_texture
			
		button.keep_pressed_outside = true
		button.expand = true
		button.stretch_mode = TextureButton.STRETCH_SCALE
		button.rect_min_size = Vector2(96, 96)
		button.connect("pressed", self, "_on_level_button_pressed", [level])
		
		grid.add_child(button)
		
func _on_button_down(button):
	var label = button.get_meta("label")
	label.rect_position = Vector2(2, 1)  # Move label down a bit (adjust as needed)

func _on_button_up(button):
	var label = button.get_meta("label")
	label.rect_position = Vector2(2, -5) # Reset label position
	
#func _on_mouse_up(var button):
#	var tween = button.get_meta("tween")
#	resetTween(tween)
#	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
#	tween.tween_property(button, "rect_scale", Vector2.ONE, 0.4)
#
#func _on_mouse_down(var button):
#	var tween = button.get_meta("tween")
#	resetTween(tween)
#	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
#	tween.tween_property(button, "rect_scale", Vector2(1.05, 1.05), 0.4)
	
func _on_level_button_pressed(lvl_num):
	# Checks if level is unlocked	
	if lvl_num <= Global.unlkd:
		
		# If unlocked level has been picked , set global variable and go to game
		Global.set_lvl(lvl_num)
		var next_scene = preload("res://Scenes/Menus/main.tscn")
		get_tree().change_scene_to(next_scene)


func _process(delta):
	$parallax_bg.scroll_offset += scroll_speed * delta

