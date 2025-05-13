extends Control

var scenery
var original_position: Vector2

func _ready():
	scenery = $Scenery
	original_position = Vector2(480, 270)
	scenery.animation = "default"
	
	var tween = create_tween()
	var camera = $Camera
	var camera_pos = Vector2(495, 456)
	var zoom = Vector2(0.01, 0.01)  # Smaller values = zoom in
	var target_zoom = Vector2(1, 1)
	var target_pos = Vector2(480, 270)
	
	camera.position = camera_pos
	tween.parallel().tween_property(camera, "global_position", target_pos, 3.0).set_trans(Tween.EASE_IN).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(camera, "zoom", target_zoom, 3.0).set_trans(Tween.EASE_IN).set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(self, "_start_shake")
	
func _start_shake():
	$Shake.start()

func _on_Shake_timeout():
	shake()
	
func shake():
	var shake_strength = 20
	var shake_duration = 0.5
	var shake_times = 5
	var interval = shake_duration / shake_times

	var tween = create_tween()
	for i in range(shake_times):
		var offset = Vector2(
			rand_range(-shake_strength, shake_strength),
			rand_range(-shake_strength, shake_strength)
		)
		tween.tween_property(scenery, "position", original_position + offset, interval).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(scenery, "position", original_position, interval).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(self, "_on_shake_finished")
		
func _on_shake_finished():
	scenery.animation = "red"
	$Rect.start()

func _on_Rect_timeout():
	$Black.visible = true
	$Label.start()

func _on_End_timeout():
	var scene = load("res://Scenes/Menus/Menu.tscn") 
	get_tree().change_scene_to(scene)

func _on_Label_timeout():
	var label = $TheEnd  # Replace with your actual Label node path
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	$Label2.start()

func _on_Label2_timeout():
	var label = $TheEnd
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	$End.start()
