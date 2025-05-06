extends Control

var scroll_speed := Vector2(50, 0)

func _ready():
	var rect = $parallax_bg/ParallaxLayer/bg2
	var target_color = Color(22/255.0, 196/255.0, 127/255.0, 1)
	var timer = $tween_bg
	var play = $Play
	
	$parallax_bg/ParallaxLayer/bg.modulate.a = 0.0
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

func _process(delta):
	$parallax_bg.scroll_offset += scroll_speed * delta


func _on_Play_pressed():
	start_game()


func _on_tween_bg_timeout():
	var tween = get_node("Tween")
	var sprite = $parallax_bg/ParallaxLayer/bg
	
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
	
