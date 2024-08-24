extends Node2D

var level_path = "res://Data/levels.json"
var equality = ""
var operator_arr = []
var number_arr = []

func _ready():
	#var level_data = ResourceLoader.load(level_path)  
	#hello its me ian im commenting
	
	var level_data = {
		"numbers": ["1", "1", "2"],
		"num_nums": 3,
		"operators": ["+", "="],
		"num_ops":2,
		"expected": "1+1=2",
	}
	
	#level_data = JSON.parse(level_data.get_string())

	print(level_data)
	
	# Access and print data
	print("Number: ", level_data["numbers"][2])
	print("Operator: ", level_data["operators"][1])

	# Convert data to JSON string
	var json_str = JSON.print(level_data)
	print("JSON String:", json_str)
	
	for i in range(level_data["num_nums"]):
		var num_instance = load("res://number.tscn").instance()
		num_instance.init_number(level_data["numbers"][i])
		num_instance.position = Vector2(i * 100 + 200, 0)
		add_child(num_instance)
		num_instance.connect("number_clicked", self, "_on_number_clicked")
		number_arr.append(num_instance)
		
		
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
	update_label()

# signal received from number instance being clicked
func _on_number_clicked(var value):
	print("added to expression:", value)
	equality += value
	update_label()

# evaluate expression button
func _on_evaluate_pressed():
	var equality_sides = equality.split("=")
	
	var expression_ls = Expression.new()
	var expression_rs = Expression.new()
	
	expression_ls.parse(equality_sides[0])
	expression_rs.parse(equality_sides[1])
	
	if (expression_ls.execute() == expression_rs.execute()):
		print("true")
	else:
		print("false")

# clear button
func _on_clear_pressed():
	equality = ""
	update_label()
	
	for i in range(number_arr.size()):
		number_arr[i].clear()
		
	for j in range(operator_arr.size()):
		operator_arr[j].clear()
	
func update_label():
	var label = $equality
	label.set_text(equality)
