extends Node2D

var positions = []

# Method to add a new position (pair of x and y)
func add_position(x: float, y: float):
	positions.append(Vector2(x, y))
	
func remove_position(x: float, y: float):
	var check_pos = Vector2(x, y)
	if positions.has(check_pos):
		positions.erase(check_pos)  # Removes the first occurrence of the position

# Method to check if a specific position (x, y) is already occupied
func is_occupied(x: float, y: float) -> bool:
	var check_pos = Vector2(x, y)
	return positions.has(check_pos)

# Method to retrieve all stored positions
func get_positions() -> Array:
	return positions

# Method to clear all positions
func clear_positions():
	positions.clear()
	
func move(oldx: int, oldy: int, newx: int, newy: int):
	
	if (!is_occupied(newx, newy)):
		remove_position(oldx, oldy)
		add_position(newx, newy)
		return true
	else:
		return false
