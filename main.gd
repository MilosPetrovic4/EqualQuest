extends Node2D

var level_path = "res://Data/levels.json"
var equality = ""
var operator_arr = []
var number_arr = []

# Current level that is being played
var current_level

# The number of characters in the level
var total_chars

# The number of characters that have been used in an equation
var solved_chars = 0

# Temporary variable representing number of currently selected characters
var total_selected = 0

func _ready():
	var level_data = {
		"numbers": ["1", "1", "2"],
		"num_nums": 3,
		"operators": ["+", "="],
		"num_ops":2,
		"num_chars":5,
		"expected": "1+1=2",
	}
	
	total_chars = level_data["num_chars"]

	# Convert data to JSON string
	var json_str = JSON.print(level_data)
	print("JSON String:", json_str)
	
	# Based on level data generate number characters
	for i in range(level_data["num_nums"]):
		var num_instance = load("res://number.tscn").instance()
		num_instance.init_number(level_data["numbers"][i])
		num_instance.position = Vector2(i * 100 + 200, 0)
		add_child(num_instance)
		num_instance.connect("number_clicked", self, "_on_number_clicked")
		number_arr.append(num_instance)
	
	# Based on level data generate operator characters
	for j in range(level_data["num_ops"]):
		var op_instance = load("res://operator.tscn").instance()
		op_instance.init_operator(level_data["operators"][j])
		op_instance.position = Vector2(j * 100 + 200, 200)
		add_child(op_instance)
		op_instance.connect("operator_clicked", self, "_on_operator_clicked")
		operator_arr.append(op_instance)

# signal received from operator instance being clicked
func _on_operator_clicked(var value):
	print("added to expression:", value)
	equality += value
	total_selected += 1
	update_label()

# signal received from number instance being clicked
func _on_number_clicked(var value):
	print("added to expression:", value)
	equality += value
	total_selected += 1
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
		
		# Level complete when solved_chars == total_chars
		if (solved_chars == total_chars):
			print("Complete")
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
	equality = ""
	total_selected = 0
	solved_chars = 0

func _on_restart_pressed():
	clear_level()
	_ready()
