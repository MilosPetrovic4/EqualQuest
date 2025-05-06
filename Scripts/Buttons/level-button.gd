extends Node

var tween

func _ready():
	connect("mouse_entered", self, "_on_level_mouse_entered")
	connect("mouse_exited", self, "_on_level_mouse_exited")
	

func resetTween():
	if tween:
		tween.kill()
	tween = create_tween()

func _on_level_mouse_exited():
	resetTween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "rect_scale", Vector2(1.0, 1.0), 0.4)

func _on_level_mouse_entered():
	resetTween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "rect_scale", Vector2(1.1, 1.1), 0.4)
