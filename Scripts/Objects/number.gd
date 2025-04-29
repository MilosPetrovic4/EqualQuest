extends StaticBody2D

signal number_dropped

var value = "0"
var dragging : bool
var completed : bool
var of = Vector2(0,0)
var select_pos = -1
const snap = 64

const knob = 1
const hole = 0

var UP = hole
var DOWN = hole
var RIGHT = hole
var left = hole

func _ready():
	dragging = false
	completed = false
	$Piece.animation = "default"
	$Piece.frame = int(value)

func setCompleted():
	completed = true
	$Piece.animation = "done"
	$Piece.frame = int(value)
#	modulate = Color(1, 1, 1, 0.5)

func setNotCompleted():
	completed = false
	$Piece.animation = "default"
	$Piece.frame = int(value)
#	modulate = Color(1, 1, 1, 1)
	
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
#	var text = $char

			
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

			

func _on_Number_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var mouse_button = event.button_index
		if event.pressed && (mouse_button == BUTTON_RIGHT || mouse_button == BUTTON_LEFT):
					
				dragging = !dragging
				if !dragging:
					emit_signal("number_dropped", position, self)
				else: # smooth out the selection so it doesn't matter where you click the object
					var mouse = get_global_mouse_position()
					position.x  = stepify(mouse.x - of.x, snap)
					position.y  = stepify(mouse.y - of.y, snap)
