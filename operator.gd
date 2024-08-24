extends StaticBody2D

signal operator_clicked
var op_type = "NA";
var selected = false
var lifted = false

func _ready():
	pass

func init_operator(var op):
	op_type = op
	var text = $text
	text.set_text(op_type)
	print("init operator")
	
func _unhandled_input(event):
	if event is InputEventMouseButton and not event.pressed:
		lifted = false
	if lifted and event is InputEventMouseMotion:
		position += event.relative


func _on_Operator_input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton:
		var mouse_button = event.button_index
		
		if event.pressed && mouse_button == BUTTON_LEFT:

				if selected == false:
					print("Value: " , op_type)
					selected = true
					emit_signal("operator_clicked", op_type)
				else:
					print("already selected")
					
		if event.pressed && mouse_button == BUTTON_LEFT:
			lifted = true

func clear():
	print("test")
	if selected == true:
		selected = false
