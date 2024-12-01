extends Node2D

var level_path = "res://Data/levels.json"
var equality : String
var operator_arr = []
var number_arr = []
var selected_order = []
var popup_menu : bool = false
var menu : Node = null

var level
var level_data

# The number of characters in the level
var total_chars

# The number of characters that have been used in an equation
var solved_chars = 0

# Temporary variable representing number of currently selected characters
var total_selected = 0

func _ready() -> void:
	
	level = Global.cur_lvl
	
	# To line up variable with array , the first element is at pos 0
	if level:
		level -= 1
	
	# load the json file
	var level_data = load_json(level_path)
	equality = ""
	total_chars = level_data[str(level)]["num_chars"]
	
	# Based on level data generate number characters
	for i in range(level_data[str(level)]["num_nums"]):
		var num_instance = load("res://Scenes/Objects/number.tscn").instance()
		num_instance.init_number(level_data[str(level)]["numbers"][i])
		num_instance.position = Vector2(i * 64 + 160, 96)
		add_child(num_instance)
		num_instance.connect("number_clicked", self, "_on_number_clicked")
		num_instance.connect("number_deselect", self, "_on_number_deselect")
		number_arr.append(num_instance)
	
	# Based on level data generate operator characters
	for j in range(level_data[str(level)]["num_ops"]):
		var op_instance = load("res://Scenes/Objects/operator.tscn").instance()
		op_instance.init_operator(level_data[str(level)]["operators"][j])
		op_instance.position = Vector2(j * 64 + 160, 170)
		add_child(op_instance)
		op_instance.connect("operator_clicked", self, "_on_operator_clicked")
		op_instance.connect("operator_deselect", self, "_on_operator_deselect")
		operator_arr.append(op_instance)
		
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

#	menu.position = Vector2(500, 0)  # Example position (adjust as needed)

# signal received from operator instance being clicked
func _on_operator_clicked(var value, var this) -> void:
	equality += value
	total_selected += 1
	var pos_in_queue = total_selected - 1
	selected_order.push_back(this)
	print(selected_order)
	this.setSelectedPos(pos_in_queue)
	update_label()

# signal received from number instance being clicked
func _on_number_clicked(var value, var this) -> void:
	equality += value
	total_selected += 1
	var pos_in_queue = total_selected - 1
	selected_order.push_back(this)
	print(selected_order)
	this.setSelectedPos(pos_in_queue)
	update_label()
	
func _on_operator_deselect(pos_in_arr : int) -> void:
	total_selected -= 1
	selected_order.remove(pos_in_arr)
	for i in range(pos_in_arr, selected_order.size(), 1):
		selected_order[i].setSelectedPos(i)
	if pos_in_arr >= 0 and pos_in_arr < equality.length():
		equality = equality.substr(0, pos_in_arr) + equality.substr(pos_in_arr + 1, equality.length() - pos_in_arr - 1)
		update_label()

func _on_number_deselect(pos_in_arr : int) -> void:
	total_selected -= 1
	selected_order.remove(pos_in_arr)
	for i in range(pos_in_arr, selected_order.size(), 1):
		selected_order[i].setSelectedPos(i)
		
	if pos_in_arr >= 0 and pos_in_arr < equality.length():
		equality = equality.substr(0, pos_in_arr) + equality.substr(pos_in_arr + 1, equality.length() - pos_in_arr - 1)
		update_label()

# Checks that expression is valid
func validate_expression(equation : String) -> bool:
	var equals_count = 0
	var equals = ["=", ">", "<"]
	var operators = ["=", ">", "+", "-", "*"]
	var digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	var last_char_op = false
	
	# Checks first and last characters are digits
	if !(equation[0] in digits) || !(equation[equation.length() - 1] in digits):
		return false
		
	for i in range(1, equation.length() - 1):
		var curr_char = equation[i]
		
		if curr_char in operators && last_char_op == true:
			return false
		
		elif curr_char in operators && last_char_op == false:
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

# evaluate expression button
func _on_evaluate_pressed() -> void:
	
	# stops the function if equation is not valid
	var valid = validate_expression(equality)
	if !valid:
		print("invalid")
		return
	
	var equality_sides = equality.split("=") #ISSUE: using split(=) if we want to use > < 
	var expression_ls = Expression.new()
	var expression_rs = Expression.new()
	
	expression_ls.parse(equality_sides[0])
	expression_rs.parse(equality_sides[1])
	
	if (expression_ls.execute() == expression_rs.execute()):
		print("true")
		equality = ""
		update_label()
		# Deletes operators that were selected when expression evaluated to true
		for i in range(operator_arr.size()-1, -1, -1):
			if (operator_arr[i].getSelected()):
				var temp_op = operator_arr[i]
				operator_arr.remove(i)
				temp_op.queue_free()
				
		# Deletes numbers that were selected when expression evaluated to true
		for j in range(number_arr.size()-1, -1, -1):
			if (number_arr[j].getSelected()):
				var temp_num = number_arr[j]
				number_arr.remove(j)
				temp_num.queue_free()
		
		solved_chars += total_selected
		total_selected = 0
		
		print("solved_chars: ")
		print(solved_chars)
		
		# Level complete when solved_chars == total_chars
		if (solved_chars == total_chars):
			print("Complete")
			clear_level()
			
			# Increments current level
			level += 2
			Global.next_lvl()
			
			# Checks if we should unlock next level
			if level > Global.unlkd:
				Global.unlock()
			
			_ready()
	else:
		print("false")

# clear button
func _on_clear_pressed() -> void:
	equality = ""
	update_label()
	total_selected = 0
	solved_chars = 0
	
	# Sets number & operator class 'selected' variable back to false
	for i in range(number_arr.size()):
		number_arr[i].clear()
		
	for j in range(operator_arr.size()):
		operator_arr[j].clear()
	
func update_label() -> void:
	var label = $equality
	label.set_text(equality)

func clear_level() -> void:
	# Iterates through every child in the scene and removes if not label or button
	for child in get_children():
		if child is TextureButton or child is Button or child is Label or child is CanvasLayer:
			continue
		else:
			child.queue_free()
	
	# Reset arrays and variables
	operator_arr.clear()
	number_arr.clear()
	selected_order.clear()
	equality = ""
	update_label()
	total_selected = 0
	solved_chars = 0

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


