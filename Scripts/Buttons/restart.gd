extends TextureButton


var tween

func resetTween():
	if tween:
		tween.kill()
	tween = create_tween()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_restart_mouse_entered():
	resetTween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "rect_scale", Vector2(6.4, 6.4), 0.4)



func _on_restart_mouse_exited():
	resetTween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "rect_scale", Vector2(6.0, 6.0), 0.4)
