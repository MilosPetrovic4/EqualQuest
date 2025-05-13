extends StaticBody2D

signal operator_dropped

var op_type = "NA";
var dragging : bool
var completed : bool
var locked = false
var tween

var snap = 64
var select_pos = -1
var of = Vector2(0,0)

const knob = 1
const hole = 0

const add = "plus"
const minus = "minus"
const mult = "times"
const div = "divide"
const lessthan = "lessthan"
const equal = "equal"

const done = "-g"
const notdone = "-r"
const locked_str = "-l"

var notdoneframe
var doneframe

var UP = knob
var DOWN = knob
var RIGHT = knob
var left = knob

signal op_piece_pressed(piece)

func _ready():
	dragging = false
	completed = false
	
func resetTween():
	if tween:
		tween.kill()
	tween = create_tween()

func setCompleted():
	completed = true
	$Piece.animation = doneframe

func setNotCompleted():
	completed = false
	$Piece.animation = notdoneframe

func getCompleted():
	return completed

func getValue():
	return op_type

func getSelectedPos():
	return select_pos
	
func setSelectedPos(pos : int):
	select_pos = pos

func init_operator(var op):
	op_type = op
	choose_frame()
	
func choose_frame():
	match op_type:
		"=":
			notdoneframe = equal #+ notdone
			doneframe = equal #+ done
		"+":
			notdoneframe = add #+ notdone
			doneframe = add #+ done
		"-":
			notdoneframe = minus #+ notdone
			doneframe = minus #+ done
		"*":
			notdoneframe = mult #+ notdone
			doneframe = mult #+ done
		"/":
			notdoneframe = div #+ notdone
			doneframe = div #+ done
		"<":
			notdoneframe = lessthan #+ notdone
			doneframe = lessthan #+ done
			
	doneframe += done
	notdoneframe += notdone
	
	if locked:
		doneframe += "-l"
		notdoneframe += "-l"
			
	$Piece.animation = notdoneframe
	$Piece.animation = notdoneframe

func _process(_delta):
	if dragging:
		var oldx: float = position.x
		var oldy: float = position.y

		var mouse = get_global_mouse_position()

		# Snap to grid
		var new_x = stepify(mouse.x - of.x, snap)
		var new_y = stepify(mouse.y - of.y, snap)

		# Clamp within bounding box: (192, 128) to (768, 448)
		new_x = clamp(new_x, 192, 832)
		new_y = clamp(new_y, 128, 448)

		var moved: bool = Positions.move(oldx, oldy, new_x, new_y)

		if moved:
			position.x = new_x
			position.y = new_y

func select_tween():
	resetTween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.4)
	
func deselect_tween():
	resetTween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)
	
func _on_Operator_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			emit_signal("op_piece_pressed", self)  # Tell main scene this piece was clicked

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
		return
	else:
		choose_frame()
		
func get_locked():
	return locked


