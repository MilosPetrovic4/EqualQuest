extends Node2D

var equality = ""

func _ready():
	# Define JSON-like data using dictionaries and arrays
	var player_data = {
		"numbers": ["1", "1", "2"],
		"operators": ["+", "="],
		"expected": "1+1=2",
	}
	
	# Access and print data
	print("Number: ", player_data["numbers"][2])
	print("Operator: ", player_data["operators"][1])

	# Convert data to JSON string
	var json_str = JSON.print(player_data)
	print("JSON String:", json_str)
	
	for i in range(3):
		var num_instance = load("res://number.tscn").instance()
		num_instance.init_number(player_data["numbers"][i])
		num_instance.position = Vector2(i * 100 + 200, 0)
		add_child(num_instance)
		


func _on_Button_pressed():
	
	var equality_sides = equality.split("=")
	
	var expression_ls = Expression.new()
	var expression_rs = Expression.new()
	
	expression_ls.parse(equality_sides[0])
	expression_rs.parse(equality_sides[1])
	
	if (expression_ls.execute() == expression_rs.execute()):
		print("true")
	else:
		print("false")
	
	expression.parse(equality)
	#var result = expression.execute()
	#print("Result: ", result)
	



