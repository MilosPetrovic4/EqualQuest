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
#	var text = $char

			
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

func _on_Number_input_event(_viewport, event, _shape_idx):
	
	# not being currently dragged and there is a selected block, no selection allowed
	if(!dragging && Global.selected):
		return
	
	# locking mechanism to prevent user from interacting with piece
	if(locked): 
		dragging = false
		return

	if event is InputEventMouseButton:
		self.raise()
		var mouse_button = event.button_index
		if event.pressed && (mouse_button == BUTTON_RIGHT || mouse_button == BUTTON_LEFT):

				dragging = !dragging
				if !dragging:
					emit_signal("number_dropped")
					Global.selected = false
					
					resetTween()
					tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
					tween.tween_property(self, "scale", Vector2.ONE, 0.4)
					
				else: # smooth out the selection so it doesn't matter where you click the object
					snapPosition()
					Global.selected = true
					
					resetTween()
					tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
					tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.4)

func snapPosition():
	var mouse = get_global_mouse_position()
	position.x  = stepify(mouse.x - of.x, snap)
	position.y  = stepify(mouse.y - of.y, snap)

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
