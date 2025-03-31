extends StaticBody2D

signal operator_clicked
signal operator_deselect

var op_type = "NA";
var selected = false
var dragging = false
var snap = 64
var select_pos = -1
var of = Vector2(0,0)
var default_modulate : Color
var selected_modulate : Color

func _ready():
	default_modulate = Color(1, 1, 1, 1)
	selected_modulate = Color(1, 1, 1, 0.5)

func getSelectedPos():
	return select_pos
	
func setSelectedPos(pos : int):
	select_pos = pos

func getSelected():
	return selected

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
		


#		if position.x < 128:
#			position.x = 128
#		elif position.x > 896:
#			position.x = 896
#
#		if position.y < 128:
#			position.y = 128
#		elif position.y > 448:
#			position.y = 448


func _on_Operator_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var mouse_button = event.button_index
		if event.pressed && mouse_button == BUTTON_RIGHT:
			dragging = true
			of = get_global_mouse_position() - global_position
		elif event.pressed && mouse_button == BUTTON_LEFT:
			if selected == false:
				print("Value: " , op_type)
				selected = true
				modulate = selected_modulate
				emit_signal("operator_clicked", op_type, self)
			else:
				selected = false
				modulate = default_modulate
				emit_signal("operator_deselect", select_pos)
		else:
			dragging = false
					

func clear():
	print("test")
	if selected == true:
		selected = false
		modulate = default_modulate
