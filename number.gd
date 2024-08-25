extends StaticBody2D

signal number_clicked
var value = "0";
var selected = false
var dragging = false
var snap = 64
var of = Vector2(0,0)

func getSelected():
	return selected

func init_number(var num):
	value = str(num)
	var text = $text
	text.set_text(value)
	
func _process(delta):
	if dragging:
		position  = get_global_mouse_position() - of
#		position = snap(position, snap)
	
func _on_Number_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var mouse_button = event.button_index
		if event.pressed && mouse_button == BUTTON_RIGHT:
			dragging = true
			of = get_global_mouse_position() - global_position
		elif event.pressed && mouse_button == BUTTON_LEFT:
			if selected == false:
				print("Value: " , value)
				emit_signal("number_clicked", value)	
				selected=true
			else:
				print("already selected")
		else:
			dragging = false

func clear():
	print("test")
	if selected == true:
		selected = false
		
# NOT IN USE CURRENTLY , TRYING TO IMPLEMENT THE SNAPPED METHOD THAT WAS ADDED IN GODOT 4
func snap(vector: Vector2, grid_size: int) -> Vector2:
	var snapped_x = round(vector.x / grid_size) * grid_size
	var snapped_y = round(vector.y / grid_size) * grid_size
	return Vector2(snapped_x, snapped_y)
