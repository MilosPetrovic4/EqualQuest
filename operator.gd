extends StaticBody2D

signal operator_clicked
var op_type = "NA";

func _ready():
	pass

func init_operator(var op):
	op_type = op
	var text = $text
	text.set_text(op_type)

func _on_operator_input_event(viewport, event, shape_idx):
	
	print("test")
	if event is InputEventMouseButton:
		var mouse_button = event.button_index
		
		if event.pressed:
		
			if mouse_button == BUTTON_LEFT:
				
				print("Value: " , op_type)
				
				emit_signal("operator_clicked", op_type)
				
				
				
				#var expression = Expression.new()
				#expression.parse("20+15 / 5")
				#var result = expression.execute()
				#print("Result: ", result)
				
				
