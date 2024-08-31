extends Control


func _on_Button_pressed():
	start_game()

func start_game():
	var scene = load("res://levels.tscn")
	get_tree().change_scene_to(scene)
