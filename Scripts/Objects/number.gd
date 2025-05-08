extends StaticBody2D

signal number_dropped

var value = "0"
var dragging : bool
var completed : bool
var of = Vector2(0,0)
var select_pos = -1
var locked = false
var tween

const snap = 64

const knob = 1
const hole = 0

var UP = hole
var DOWN = hole
var RIGHT = hole
var left = hole

signal num_piece_pressed(piece)

func _ready():
	dragging = false
	completed = false
	$Piece.animation = "default"
	$Piece.frame = int(value)
	
func resetTween():
	if tween:
		tween.kill()
	tween = create_tween()

func setCompleted():
	completed = true
	setGreenSprite()

func setNotCompleted():
	completed = false
	setRedSprite()
	
func setGreenSprite():
	if locked:
		$Piece.animation = "locked-done"
	else:
		$Piece.animation = "done"
	$Piece.frame = int(value)

func setRedSprite():
	if locked:
		$Piece.animation = "locked"
	else:
		$Piece.animation = "default"
	$Piece.frame = int(value)
	
func getCompleted():
	return completed

func getValue():
	return value
	
func getSelectedPos():
	return select_pos
	
func setSelectedPos(pos : int):
	select_pos = pos

func init_number(var num):
	value = str(num)

func select_tween():
	resetTween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.4)
	
func deselect_tween():
	resetTween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)

func _on_Number_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			emit_signal("num_piece_pressed", self)

func emit_green():
	$success.color = Color(0, 255, 0)
	$success.emitting = true
	$success.restart()
	
func emit_red():
	$success.color = Color(255, 0, 0)
	$success.emitting = true
	$success.restart()
	
func lock_piece():
	locked = true
	if completed:
		setGreenSprite()
	else:
		setRedSprite()
