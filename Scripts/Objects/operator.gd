extends StaticBody2D

signal operator_dropped

var op_type = "NA";
var dragging : bool
var completed : bool
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

var notdoneframe
var doneframe

var UP = knob
var DOWN = knob
var RIGHT = knob
var left = knob

func _ready():
	dragging = false
	completed = false

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
#	var text = $char

	match op_type:
		"=":
			notdoneframe = equal + notdone
			doneframe = equal + done
		"+":
			notdoneframe = add + notdone
			doneframe = add + done
		"-":
			notdoneframe = minus + notdone
			doneframe = minus + done
		"*":
			notdoneframe = mult + notdone
			doneframe = mult + done
		"/":
			notdoneframe = div + notdone
			doneframe = div + done
		"<":
			notdoneframe = lessthan + notdone
			doneframe = lessthan + done
			
	$Piece.animation = notdoneframe

func _process(delta):
	if dragging:
		var oldx: int = position.x
		var oldy: int = position.y

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

func _on_Operator_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var mouse_button = event.button_index
		if event.pressed && (mouse_button == BUTTON_RIGHT || mouse_button == BUTTON_LEFT):
			dragging = !dragging
			if !dragging:
				emit_signal("operator_dropped", position, self)
			else: # smooth out the selection so it doesn't matter where you click the object
				var mouse = get_global_mouse_position()
				position.x  = stepify(mouse.x - of.x, snap)
				position.y  = stepify(mouse.y - of.y, snap)

