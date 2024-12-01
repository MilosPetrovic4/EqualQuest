extends Control


func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		start_game()

func start_game():
	var next_scene = preload("res://Scenes//Menus/levels.tscn")
	get_tree().change_scene_to(next_scene)
