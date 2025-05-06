extends TextureButton

var tween

func resetTween():
	if tween:
		tween.kill()
	tween = create_tween()

func _on_next_mouse_exited():
	resetTween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "rect_scale", Vector2(4.0, 4.0), 0.4)

func _on_next_mouse_entered():
	resetTween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "rect_scale", Vector2(4.2, 4.2), 0.4)
