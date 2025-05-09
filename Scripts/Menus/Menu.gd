extends Control

var scroll_speed := Vector2(50, 0)

var rect
var timer
var play
var title
var scenery

func _ready():
	var target_color = Color(17/255.0, 20/255.0, 51/255.0, 1)
	rect = $bg2
	timer = $timers/tween_bg
	play = $Play
	title = $Title
	scenery = $Scenery
	
	scenery.modulate.a = 0.0
	play.modulate.a = 0.0
	title.modulate.a = 0.0
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
	$timers/wait.start()
	play.disabled = true
	
	var tween = get_node("Tween")
	
	tween.interpolate_property(title, "modulate:a",
	1.0, 0.0, 1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.interpolate_property(play, "modulate:a",
	1.0, 0.0, 1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	tween.start()

func _on_tween_bg_timeout():
	var tween = get_node("Tween")

	tween.interpolate_property(scenery, "modulate:a",
	0.0, 1.0, 1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.start()
	$timers/tween_play.start()

func _on_tween_play_timeout():
	var tween = get_node("Tween")
	
	tween.interpolate_property(play, "modulate:a",
	0.0, 1.0, 1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.interpolate_property(title, "modulate:a",
	0.0, 1.0, 1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.start()
	play.disabled = false

func _on_transition_timeout():
	start_game()

func _on_wait_timeout():
	var tween = create_tween()
	var camera = $camera
	var target_position = Vector2(495, 456)
	var target_zoom = Vector2(0.01, 0.01)  # Smaller values = zoom in

	tween.parallel().tween_property(camera, "global_position", target_position, 3.0).set_trans(Tween.EASE_IN).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(camera, "zoom", target_zoom, 3.0).set_trans(Tween.EASE_IN).set_ease(Tween.EASE_OUT)
	$timers/transition.start()



