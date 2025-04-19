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

var UP = knob
var DOWN = knob
var RIGHT = knob
var left = knob

func _ready():
	dragging = false
	completed = false

func setCompleted():
	completed = true
	modulate = Color(1, 1, 1, 0.5)

func setNotCompleted():
	completed = false
	modulate = Color(1, 1, 1, 1)

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
	var text = $char
	text.set_text(op_type)

func _process(delta):
	if dragging:
		var oldx: int = position.x
		var oldy: int = position.y

		var mouse = get_global_mouse_position()

		var moved: bool = Positions.move(oldx, oldy, stepify(mouse.x - of.x, snap), stepify(mouse.y - of.y, snap))
		
		if (moved):
			position.x  = stepify(mouse.x - of.x, snap)
			position.y  = stepify(mouse.y - of.y, snap)

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

