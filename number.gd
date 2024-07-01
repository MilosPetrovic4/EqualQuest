extends StaticBody2D

signal number_clicked
var value = 0;

func _ready():
	var text = $text
	text.set_text(value)

func init_number(var num):
	value = num

func _on_Number_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var mouse_button = event.button_index
		
		if event.pressed:
		
			if mouse_button == BUTTON_LEFT:
				
				print("Value: " , value)
				
				emit_signal("number_clicked", value)
				
				
				
				#var expression = Expression.new()
				#expression.parse("20+15 / 5")
				#var result = expression.execute()
				#print("Result: ", result)
				
				

