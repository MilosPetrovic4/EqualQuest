extends StaticBody2D

signal number_clicked
var value = "0";
var selected = false

func _ready():
	#self.connect("clear_sig", self, "_on_clear_pressed")
	pass

func init_number(var num):
	value = str(num)
	var text = $text
	text.set_text(value)

func _on_Number_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var mouse_button = event.button_index
		
		if event.pressed && mouse_button == BUTTON_LEFT:
				
				if selected == false:
					print("Value: " , value)
					emit_signal("number_clicked", value)	
					selected=true
					
					
				else:
					print("already selected")
					
func clear():
	print("test")
	if selected == true:
		selected = false
		


