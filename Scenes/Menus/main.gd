extends Node2D

var level_path = "res://Data/levels.json"
var puzzle_pieces = []
var selected_order = []
var popup_menu : bool = false
var menu : Node = null
const TILE_SIZE = 64
const persistent = "persist"
const equals = ["=", "<"]
const operators = ["=", "<", "+", "-", "*"]
const digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

var level
var level_data

# The number of characters in the level
var total_chars

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
		num_instance.position = Vector2(i * 64 + 192, 128)
		Positions.add_position(i * 64 + 192, 128)
		add_child(num_instance)
		num_instance.connect("number_dropped", self, "_on_number_dropped")
		puzzle_pieces.append(num_instance)
	
	# Based on level data generate operator characters
	for j in range(level_data[str(level)]["num_ops"]):
		var op_instance = load("res://Scenes/Objects/operator.tscn").instance()
		op_instance.init_operator(level_data[str(level)]["operators"][j])
		op_instance.position = Vector2(j * 64 + 192, 448)
		Positions.add_position(j * 64 + 192, 448)
		add_child(op_instance)
		op_instance.connect("operator_dropped", self, "_on_operator_dropped")
		puzzle_pieces.append(op_instance)
		
	set_level_name(level_data[str(level)]["name"])
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_esc_pressed()

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
	
	# stops the function if equation is not valid
	var valid = validate_expression(eq)
	if !valid:
		for i in range(adjacent_objects.size()):
			if adjacent_objects[i].getCompleted():
				adjacent_objects[i].setNotCompleted()
				adjacent_objects[i].emit_red()
		return
	
	var equality_sides

	if "=" in eq:
		equality_sides = eq.split("=")
		
		var expression_ls = Expression.new()
		var expression_rs = Expression.new()
		
		expression_ls.parse(equality_sides[0])
		expression_rs.parse(equality_sides[1])
		
		# Expression holds true
		if (expression_ls.execute() == expression_rs.execute()):
			for i in range(adjacent_objects.size()):
				if !adjacent_objects[i].getCompleted(): # was false before, becomes true
					adjacent_objects[i].setCompleted()
					adjacent_objects[i].emit_green()
			for obj in puzzle_pieces:
				if !obj.getCompleted():
					return
					
			$Done.start()
		else:
			for i in range(adjacent_objects.size()):
				if adjacent_objects[i].getCompleted():
					adjacent_objects[i].setNotCompleted()
					adjacent_objects[i].emit_red()
			
	elif "<" in eq:
		equality_sides = eq.split("<")

		var expression_ls = Expression.new()
		var expression_rs = Expression.new()
		
		expression_ls.parse(equality_sides[0])
		expression_rs.parse(equality_sides[1])
		
		# Expression holds true
		if(expression_ls.execute() < expression_rs.execute()):
			for i in range(adjacent_objects.size()):
				if !adjacent_objects[i].getCompleted(): # was false before, becomes true
					adjacent_objects[i].setCompleted()
					adjacent_objects[i].emit_green()
			for obj in puzzle_pieces:
				if !obj.getCompleted():
					return
					
			$Done.start()
		else:
			for i in range(adjacent_objects.size()):
				if adjacent_objects[i].getCompleted():
					adjacent_objects[i].setNotCompleted()
					adjacent_objects[i].emit_red()

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
		if child.is_in_group(persistent):
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


func set_level_name(var name):
	$"ui/name-str".set_text(name)
	
func del_level_name():
	$"ui/name-str".set_text("")

func _on_esc_pressed():
	if menu:
		menu.queue_free()
		menu = null
		$Buttons/esc.disabled = false
		$Buttons/restart.disabled = false
		$Buttons/menu.disabled = false
		
		for obj in puzzle_pieces:
			obj.unlock_piece()
		
	else:
		instance_popup_scene()
		$Buttons/esc.disabled = true
		$Buttons/restart.disabled = true
		$Buttons/menu.disabled = true
		
		for obj in puzzle_pieces:
			obj.lock_piece()

func _on_menu_pressed():
	Positions.clear()
	var scene = load("res://Scenes/Menus/levels.tscn")
	get_tree().change_scene_to(scene)
