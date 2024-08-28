extends Node2D

#var level_path = "res://Data/levels.json"
var equality : String
var operator_arr = []
var number_arr = []
var selected_order = []
#var level_data_arr = []
var current_level = 0
var level_data

# The number of characters in the level
var total_chars

# The number of characters that have been used in an equation
var solved_chars = 0

# Temporary variable representing number of currently selected characters
var total_selected = 0

func _ready():
	
	# load the json file
	var file_path = "res://Data/levels.json"
	var level_data = load_json(file_path)
	if level_data:
		print(level_data)
	else:
		print("Failed to load or parse JSON file.")
	
	equality = ""
	
#	var level_data1 = {
#		"numbers": ["1", "1", "2"],
#		"num_nums": 3,
#		"operators": ["+", "="],
#		"num_ops":2,
#		"num_chars":5,
#		"expected": "1+1=2"
#	}
#
#	var level_data2 = {
#		"numbers": ["1", "2", "4", "8"],
#		"num_nums": 4,
#		"operators": ["+", "="],
#		"num_ops":2,
#		"num_chars":6,
#		"expected": "12=4+8"
#	}
#
#	level_data_arr.push_back(level_data["1"])
#	level_data_arr.push_back(level_data["2"])
	total_chars = level_data[str(current_level)]["num_chars"]
#	total_chars = level_data_arr[current_level]["num_chars"]
	
#	total_chars = level_data["num_chars"]
	# Convert data to JSON string
#	var json_str = JSON.print(level_data)
	var json_str = JSON.print(level_data[str(current_level)])
	print("JSON String:", json_str)
	
	# Based on level data generate number characters
	for i in range(level_data[str(current_level)]["num_nums"]):
		var num_instance = load("res://number.tscn").instance()
		num_instance.init_number(level_data[str(current_level)]["numbers"][i])
		num_instance.position = Vector2(i * 100 + 200, 0)
		add_child(num_instance)
		num_instance.connect("number_clicked", self, "_on_number_clicked")
		num_instance.connect("number_deselect", self, "_on_number_deselect")
		number_arr.append(num_instance)
	
	# Based on level data generate operator characters
	for j in range(level_data[str(current_level)]["num_ops"]):
		var op_instance = load("res://operator.tscn").instance()
		op_instance.init_operator(level_data[str(current_level)]["operators"][j])
		op_instance.position = Vector2(j * 100 + 200, 200)
		add_child(op_instance)
		op_instance.connect("operator_clicked", self, "_on_operator_clicked")
		op_instance.connect("operator_deselect", self, "_on_operator_deselect")
		operator_arr.append(op_instance)

# signal received from operator instance being clicked
func _on_operator_clicked(var value, var this):
	equality += value
	total_selected += 1
	var pos_in_queue = total_selected - 1
	selected_order.push_back(this)
	print(selected_order)
	this.setSelectedPos(pos_in_queue)
	update_label()

# signal received from number instance being clicked
func _on_number_clicked(var value, var this):
	equality += value
	total_selected += 1
	var pos_in_queue = total_selected - 1
	selected_order.push_back(this)
	print(selected_order)
	this.setSelectedPos(pos_in_queue)
	update_label()
	
func _on_operator_deselect(pos_in_arr : int):
	total_selected -= 1
	selected_order.remove(pos_in_arr)
	for i in range(pos_in_arr, selected_order.size(), 1):
		selected_order[i].setSelectedPos(i)
	if pos_in_arr >= 0 and pos_in_arr < equality.length():
		equality = equality.substr(0, pos_in_arr) + equality.substr(pos_in_arr + 1, equality.length() - pos_in_arr - 1)
		update_label()

func _on_number_deselect(pos_in_arr : int):
	total_selected -= 1
	selected_order.remove(pos_in_arr)
	for i in range(pos_in_arr, selected_order.size(), 1):
		selected_order[i].setSelectedPos(i)
		
	if pos_in_arr >= 0 and pos_in_arr < equality.length():
		equality = equality.substr(0, pos_in_arr) + equality.substr(pos_in_arr + 1, equality.length() - pos_in_arr - 1)
		update_label()

# evaluate expression button
func _on_evaluate_pressed():
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
			current_level += 1
			_ready()
	else:
		print("false")

# clear button
func _on_clear_pressed():
	equality = ""
	update_label()
	total_selected = 0
	solved_chars = 0
	
	# Sets number & operator class 'selected' variable back to false
	for i in range(number_arr.size()):
		number_arr[i].clear()
		
	for j in range(operator_arr.size()):
		operator_arr[j].clear()
	
func update_label():
	var label = $equality
	label.set_text(equality)

func clear_level():
	# Iterates through every child in the scene and removes if not label or button
	for child in get_children():
		if child is Button or child is Label:
			continue
		else:
			child.queue_free()
	
	# Reset arrays and variables
	operator_arr.clear()
	number_arr.clear()
	selected_order.clear()
	equality = ""
	total_selected = 0
	solved_chars = 0

func _on_restart_pressed():
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
