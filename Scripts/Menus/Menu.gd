extends Control

var scroll_speed := Vector2(50, 0)

func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		start_game()

func start_game():
	var next_scene = preload("res://Scenes//Menus/levels.tscn")
	get_tree().change_scene_to(next_scene)

func _process(delta):
	$parallax_bg.scroll_offset += scroll_speed * delta
