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
	print("SELECTING: ")
	print(pos)
	
func getSelected():
	return selected

func init_operator(var op):
	op_type = op
	var text = $text
	text.set_text(op_type)

func _process(delta):
	if dragging:
		position  = get_global_mouse_position() - of

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
