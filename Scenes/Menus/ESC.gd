extends Control


func _on_Button_pressed():
	start_game()

func start_game():
	Positions.clear()
	var scene = load("res://Scenes/Menus/levels.tscn")
	get_tree().change_scene_to(scene)
