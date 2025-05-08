extends Control

var scroll_speed := Vector2(50, 0)

func _ready():
	var rect = $bg2
	var target_color = Color(17/255.0, 20/255.0, 51/255.0, 1)
	var timer = $tween_bg
	var play = $Play
	
	$Scenery.modulate.a = 0.0
	play.modulate.a = 0.0
	play.disabled = true
	rect.color = Color(0, 0, 0, 1)
	
	var tween = get_node("Tween")
	tween.interpolate_property(rect, "color",
		rect.color, target_color, timer.wait_time - 0.2,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		
	tween.start()
	timer.start()

func start_game():
	var next_scene = preload("res://Scenes//Menus/levels.tscn")
	get_tree().change_scene_to(next_scene)

func _on_Play_pressed():
	var tween = create_tween()
	var camera = $camera
	var target_position = Vector2(495, 456)
	var target_zoom = Vector2(0.01, 0.01)  # Smaller values = zoom in

	# Interpolate position
	tween.parallel().tween_property(camera, "global_position", target_position, 3.0).set_trans(Tween.EASE_IN).set_ease(Tween.EASE_OUT)
	# Interpolate zoom
	tween.parallel().tween_property(camera, "zoom", target_zoom, 3.0).set_trans(Tween.EASE_IN).set_ease(Tween.EASE_OUT)
	$transition.start()


func _on_tween_bg_timeout():
	var tween = get_node("Tween")
	var sprite = $Scenery
	
	tween.interpolate_property(sprite, "modulate:a",
	0.0, 1.0, 1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	tween.start()
	$tween_play.start()

func _on_tween_play_timeout():
	var tween = get_node("Tween")
	var play = $Play
	
	tween.interpolate_property(play, "modulate:a",
	0.0, 1.0, 1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	tween.start()
	play.disabled = false
	

func _on_transition_timeout():
	start_game()
