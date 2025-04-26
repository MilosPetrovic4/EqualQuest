extends Node2D

var level_path = "res://Data/levels.json"
var puzzle_pieces = []
var selected_order = []
var popup_menu : bool = false
var menu : Node = null
const TILE_SIZE = 96

var level
var level_data

# The number of characters in the level
var total_chars

#GRID
func _draw() -> void:
	for z in range(48, 576, 96):
		draw_line(Vector2(0, z), Vector2(1024, z), Color(1, 0, 0), 1.0)

	for k in range(48, 1024, 96):
		draw_line(Vector2(k, 0), Vector2(k, 576), Color(1, 0, 0), 1.0)
		
	# Rules, TODO: Remove when done
#	draw_line(Vector2(0, 96), Vector2(1024, 96), Color(1, 0, 0), 1.0)
#	draw_line(Vector2(0, 448), Vector2(1024, 448), Color(1, 0, 0), 1.0)
#	draw_line(Vector2(96, 0), Vector2(96, 576), Color(1, 0, 0), 1.0)
#	draw_line(Vector2(896, 0), Vector2(896, 576), Color(1, 0, 0), 1.0)

func _ready() -> void:
	
	level = Global.cur_lvl
	
	# To line up variable with array , the first element is at pos 0
	if level:
		level -= 1
	
	# load the json file
	var level_data = load_json(level_path)
	total_chars = level_data[str(level)]["num_chars"]
	
	# Based on level data generate number characters
	for i in range(level_data[str(level)]["num_nums"]):
		var num_instance = load("res://Scenes/Objects/number.tscn").instance()
		num_instance.init_number(level_data[str(level)]["numbers"][i])
		num_instance.position = Vector2(i * 96 + 192, 96)
		Positions.add_position(i * 96 + 192, 96)
		add_child(num_instance)
		num_instance.connect("number_dropped", self, "_on_number_dropped")
		puzzle_pieces.append(num_instance)
	
	# Based on level data generate operator characters
	for j in range(level_data[str(level)]["num_ops"]):
		var op_instance = load("res://Scenes/Objects/operator.tscn").instance()
		op_instance.init_operator(level_data[str(level)]["operators"][j])
		op_instance.position = Vector2(j * 96 + 192, 192)
		Positions.add_position(j * 48 + 192, 192)
		add_child(op_instance)
		op_instance.connect("operator_dropped", self, "_on_operator_dropped")
		puzzle_pieces.append(op_instance)
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if menu:
			menu.queue_free()
			menu = null
		else:
			instance_popup_scene()

func instance_popup_scene() -> void:
	var popup: PackedScene = preload("res://Scenes/Menus/ESC.tscn")
	menu = popup.instance()
	add_child(menu)
	
func _on_operator_dropped(var pos: Vector2, var this):
	for obj in puzzle_pieces:
		evaluate(obj)
	
func _on_number_dropped(var pos: Vector2, var this):
	for obj in puzzle_pieces:
		evaluate(obj)

# Checks that expression is valid
func validate_expression(equation : String) -> bool:
	var equals_count = 0
	var equals = ["=", ">", "<"]
	var operators = ["=", "<", ">", "+", "-", "*"]
	var digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	var last_char_op = false
	
	if equation.length() == 0:
		return false
	
	# Checks first and last characters are digits
	if !(equation[0] in digits) || !(equation[equation.length() - 1] in digits):
		return false
		
	for i in range(1, equation.length() - 1):
		var curr_char = equation[i]
		
		if curr_char in operators && last_char_op:
			return false
		
		elif curr_char in operators && !last_char_op:
			last_char_op = true
			if curr_char in equals:
				equals_count += 1
			
		else:
			last_char_op = false
	
	# Checks that there is only 1 equality oeprator
	if equals_count != 1:
		return false
	
	# All tests passed return true
	return true

# utility method to get puzzle piece at certain position
func get_piece_at_position(pos: Vector2) -> Node:
	for obj in get_tree().get_nodes_in_group("piece"):
		if obj.global_position.distance_to(pos) < 1.0:
			return obj
	return null
	
func build_expression_from(start_piece: Node, adjacent_arr: Array) -> String:
	var expression = ""
	var current_pos = start_piece.global_position

	# Step 1: Go left from the start
	var pos_left = current_pos - Vector2(TILE_SIZE, 0)
	while true:
		var piece = get_piece_at_position(pos_left)
		if piece == null:
			break
		expression = str(piece.getValue()) + expression
		pos_left -= Vector2(TILE_SIZE, 0)
		adjacent_arr.append(piece)

	# Step 2: Add the center piece
	expression += str(start_piece.getValue())
	adjacent_arr.append(start_piece)

	# Step 3: Go right from the start
	var pos_right = current_pos + Vector2(TILE_SIZE, 0)
	while true:
		var piece = get_piece_at_position(pos_right)
		if piece == null:
			break
		expression += str(piece.getValue())
		pos_right += Vector2(TILE_SIZE, 0)
		adjacent_arr.append(piece)

	return expression

# evaluate expression button
func evaluate(var piece) -> void:
	var adjacent_objects = []
	var eq = build_expression_from(piece, adjacent_objects)
	print(eq)
	
	# stops the function if equation is not valid
	var valid = validate_expression(eq)
	if !valid:
		for i in range(adjacent_objects.size()):
			adjacent_objects[i].setNotCompleted()
		return
	
	var equality_sides

	if "=" in eq:
		equality_sides = eq.split("=") #ISSUE: using split(=) if we want to use > < 
		
		var expression_ls = Expression.new()
		var expression_rs = Expression.new()
		
		expression_ls.parse(equality_sides[0])
		expression_rs.parse(equality_sides[1])
		
		# Expression holds true
		if (expression_ls.execute() == expression_rs.execute()):
			for i in range(adjacent_objects.size()):
				adjacent_objects[i].setCompleted()
			for obj in puzzle_pieces:
				if !obj.getCompleted():
					return
					
			$Done.start()
			
	elif "<" in eq:
		equality_sides = eq.split("<")

		var expression_ls = Expression.new()
		var expression_rs = Expression.new()
		
		expression_ls.parse(equality_sides[0])
		expression_rs.parse(equality_sides[1])
		
		# Expression holds true
		if(expression_ls < expression_rs):
			for i in range(adjacent_objects.size()):
				adjacent_objects[i].setCompleted()
			for obj in puzzle_pieces:
				if !obj.getCompleted():
					return
					
			$Done.start()

	else:
		for i in range(adjacent_objects.size()):
			adjacent_objects[i].setNotCompleted()

# clear button
func _on_clear_pressed() -> void:

	for j in range(puzzle_pieces.size()):
		puzzle_pieces[j].clear()

func clear_level() -> void:
	# Iterates through every child in the scene and removes if not label or button
	for child in get_children():
		if child is TextureButton or child is Button or child is Label or child is CanvasLayer or child is ColorRect or child is Timer:
			continue
		else:
			child.queue_free()
	
	# Reset arrays and variables
	puzzle_pieces.clear()
	Positions.clear()
	selected_order.clear()

func _on_restart_pressed() -> void:
	clear_level()
	_ready()
	
func load_json(path: String):
	var file := File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	var parsed_json: JSONParseResult = JSON.parse(content)
	if not parsed_json.error:
		return parsed_json.result

func _on_Done_timeout():
	clear_level()
	
	# Increments current level
	level += 2
	Global.next_lvl()
	
	# Checks if we should unlock next level
	if level > Global.unlkd:
		Global.unlock()
	
	_ready()
