extends Node2D

var level_path = "res://Data/levels.json"
var puzzle_pieces = []
var selected_order = []

export var bus_name: String
var bus_index: int

var audio0 = load("res://Art/Buttons/Audio/mute.png")
var audio0p = load("res://Art/Buttons/Audio/mute-pressed.png")

var audio1 = load("res://Art/Buttons/Audio/audio1.png")
var audio1p = load("res://Art/Buttons/Audio/audio1-pressed.png")

var audio2 = load("res://Art/Buttons/Audio/audio2.png")
var audio2p = load("res://Art/Buttons/Audio/audio2-pressed.png")

var audio3 = load("res://Art/Buttons/Audio/audio3.png")
var audio3p = load("res://Art/Buttons/Audio/audio3-pressed.png")

var popup_menu : bool = false
var menu : Node = null
const TILE_SIZE = 64
const snap = 64
const persistent = "persist"
const equals = ["=", "<"]
const operators = ["=", "<", "+", "-", "*", "/"]
const digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
const epsilon = 0.0001
const MIN_X = 192
const MAX_X = 832
const MIN_Y = 128
const MAX_Y = 448
const tut1_pos = [Vector2(192, 256), Vector2(320, 256), Vector2(256, 256)]

var level
var level_data

var dragging_piece = null
var of = Vector2(0,0)

func _on_num_piece_pressed(var piece):
	dragging_piece = piece
	piece.select_tween()
	piece.raise()

func _on_op_piece_pressed(var piece):
	dragging_piece = piece
	piece.select_tween()
	piece.raise()

func _input(event):
	if dragging_piece and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		snapPosition()
		dragging_piece.deselect_tween()

		if dragging_piece.is_in_group("piece_num"):
			dragging_piece.emit_signal("number_dropped")
		elif dragging_piece.is_in_group("piece_op"):
			dragging_piece.emit_signal("operator_dropped")
			
		dragging_piece = null

func _process(_delta):
	if dragging_piece:
		snapPosition()
	
func snapPosition():
	var mouse = get_global_mouse_position()
	
	var oldx: float = dragging_piece.position.x
	var oldy: float = dragging_piece.position.y

	# Snap to grid
	var new_x = stepify(mouse.x - of.x, snap)
	var new_y = stepify(mouse.y - of.y, snap)

	# Clamp to bounding box
	new_x = clamp(new_x, MIN_X, MAX_X)
	new_y = clamp(new_y, MIN_Y, MAX_Y)

	var moved: bool = Positions.move(oldx, oldy, new_x, new_y)

	if moved:
		dragging_piece.global_position = Vector2(new_x, new_y)

func _ready() -> void:
	set_audio()
	bus_index = AudioServer.get_bus_index(bus_name)
	level = Global.cur_lvl
	
	if level >= Global.num_lvls:
		var scene = load("res://Scenes/Menus/Menu.tscn") 
		get_tree().change_scene_to(scene)
		return
		
	# To line up variable with array , the first element is at pos 0
	if level:
		level -= 1
	
	# load the json file
	var level_data = load_json(level_path)
	
	# Locked Characters
	if level_data[str(level)].has("locked_chars"):
		var pos = 0 # used for placing the piece
		for i in level_data[str(level)]["locked_chars"]:
			if str(i) in digits:
				var num_instance = create_number(i, Vector2(pos * 64 + 192, 256))
				num_instance.lock_piece()
				pos += 1
			else: # Operator characters (NOT INT -> String)
				var op_instance = create_op(i, Vector2(pos * 64 + 192, 256))
				op_instance.lock_piece()
				pos += 1
				
	var count = 0
	for i in level_data[str(level)]["numbers"]:
		create_number(i, Vector2(count * 64 + 192, 128))
		count += 1
	
	count = 0
	for j in level_data[str(level)]["operators"]:
		create_op(j, Vector2(count * 64 + 192, 448))
		count += 1
		
	for piece in get_tree().get_nodes_in_group("piece_num"):
		if not piece.is_connected("num_piece_pressed", self, "_on_num_piece_pressed"):
			piece.connect("num_piece_pressed", self, "_on_num_piece_pressed")
		
	for piece in get_tree().get_nodes_in_group("piece_op"):
		if not piece.is_connected("op_piece_pressed", self, "_on_op_piece_pressed"):
			piece.connect("op_piece_pressed", self, "_on_op_piece_pressed")
		
	set_level_name(level_data[str(level)]["name"])
	set_level_num(str((level + 1)))
	
	if (Global.cur_lvl >= Global.unlkd || Global.cur_lvl == Global.num_lvls - 1):
		disable_next()
	else:
		enable_next()
		
	if (Global.cur_lvl <= 1):
		disable_prev()
	else:
		enable_prev()
		
	#tutorial code
	if(Global.lvl_one_tut && Global.cur_lvl == 1):		
		var pos = 0
		for piece in puzzle_pieces:
			if (piece.is_in_group("piece_num")):
				var shadow = load("res://Scenes/Objects/shadow.tscn").instance()
				shadow.setFrame(piece.getValue())
				shadow.position = piece.position
				add_child(shadow)
				
				var tween = get_tree().create_tween()#.set_loops()
				var target_pos = tut1_pos[pos]
				tween.tween_property(shadow, "position", target_pos, 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).from_current()
				pos += 1
				
			elif(piece.is_in_group("piece_op")):
				var shadow = load("res://Scenes/Objects/shadow.tscn").instance()
				shadow.setFrame(piece.getValue())
				shadow.position = piece.position
				add_child(shadow)
				
				var tween = get_tree().create_tween()#.set_loops()
				var target_pos = tut1_pos[pos]
				tween.tween_property(shadow, "position", target_pos, 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).from_current()
				pos += 1

# The function that instances a number piece object
func create_number(var num, var pos_vec):
	var num_instance = load("res://Scenes/Objects/number.tscn").instance()
	num_instance.init_number(num)
	num_instance.position = pos_vec
	Positions.add_position(pos_vec.x, pos_vec.y)
	add_child(num_instance)
	num_instance.connect("number_dropped", self, "_on_number_dropped")
	puzzle_pieces.append(num_instance)
	return num_instance

# The function that instances an operator piece object
func create_op(var op, var pos_vec):
	var op_instance = load("res://Scenes/Objects/operator.tscn").instance()
	op_instance.init_operator(op)
	op_instance.position = pos_vec
	Positions.add_position(pos_vec.x, pos_vec.y)
	add_child(op_instance)
	op_instance.connect("operator_dropped", self, "_on_operator_dropped")
	puzzle_pieces.append(op_instance)
	return op_instance
	
func _on_operator_dropped():
	$click.play()
	for obj in puzzle_pieces:
		evaluate(obj)
	
func _on_number_dropped():
	$click.play()
	
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
	for obj in get_tree().get_nodes_in_group("piece_num") + get_tree().get_nodes_in_group("piece_op"):
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
				$fail.play()
		return
	
	var result := ""
	# This code appends .0 to every number to avoid flooring
	for i in range(eq.length()):
		var char_ = eq[i]
		if char_ in operators:
			result += ".0"
			result += char_
		else:
			# Handle unexpected characters (you can skip or raise error)
			result += char_
	result += ".0"
	eq = result
	
	var equality_sides
	
	if "=" in eq:
		equality_sides = eq.split("=")
#		print(equality_sides[0], "=", equality_sides[1])
		var expression_ls = Expression.new()
		var expression_rs = Expression.new()
		
		expression_ls.parse(equality_sides[0])
		expression_rs.parse(equality_sides[1])
		
		var result_ls = expression_ls.execute()
		var result_rs = expression_rs.execute()
		
		# Expression holds true
		if(abs(result_ls - result_rs) < epsilon):
			for i in range(adjacent_objects.size()):
				if !adjacent_objects[i].getCompleted(): # was false before, becomes true
					adjacent_objects[i].setCompleted()
					adjacent_objects[i].emit_green()
					$success.play()
					
			for obj in puzzle_pieces:
				if !obj.getCompleted():
					return
					
			$Done.start()
		else:
			for i in range(adjacent_objects.size()):
				if adjacent_objects[i].getCompleted():
					adjacent_objects[i].setNotCompleted()
					adjacent_objects[i].emit_red()
					$fail.play()
			
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
					$success.play()
			for obj in puzzle_pieces:
				if !obj.getCompleted():
					return
					
			$Done.start()
		else:
			for i in range(adjacent_objects.size()):
				if adjacent_objects[i].getCompleted():
					adjacent_objects[i].setNotCompleted()
					adjacent_objects[i].emit_red()
					$fail.play()

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
		elif child.is_in_group("esc"):
			child.queue_free()
			menu = null
			$Buttons/esc.disabled = false
			$Buttons/restart.disabled = false
			$Buttons/menu.disabled = false
		else:
			child.queue_free()
	
	# Reset arrays and variables
	puzzle_pieces.clear()
	Positions.clear()
	selected_order.clear()

func _on_restart_pressed() -> void:
	clear_level()
	Global.selected = false
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
	
	# Increments current level, +2 because previously did -1 to align number with array 1 -> 0th array pos
	level += 2
	Global.next_lvl()
	
	# Checks if we should unlock next level
	if level > Global.unlkd:
		Global.unlock()
		
#	if Global.cur_lvl == 1 && Global.lvl_one_tut:
	Global.lvl_one_tut = false
	
	_ready()
	
func set_level_name(var name):
	$"ui/name-str".set_text(name)
	
func set_level_num(var num):
	$"ui/level-num".set_text(num)

func _on_menu_pressed():
	Positions.clear()
	Global.selected = false
	var scene = load("res://Scenes/Menus/levels.tscn")
	get_tree().change_scene_to(scene)

func set_audio():
	match(Global.audio_state):
		0:
			$Buttons/audio.texture_normal = audio0
			$Buttons/audio.texture_pressed = audio0p
			updateAudio(0)
		1:
			$Buttons/audio.texture_normal = audio1
			$Buttons/audio.texture_pressed = audio1p
			updateAudio(0.25)
		2:
			$Buttons/audio.texture_normal = audio2
			$Buttons/audio.texture_pressed = audio2p
			updateAudio(0.5)
		3:
			$Buttons/audio.texture_normal = audio3
			$Buttons/audio.texture_pressed = audio3p
			updateAudio(0.75)
			
func _on_audio_pressed():
	
	
	
	if (Global.audio_state == 3):
		Global.audio_state = 0
	else:
		Global.audio_state += 1
	
	match(Global.audio_state):
		0:
			$Buttons/audio.texture_normal = audio0
			$Buttons/audio.texture_pressed = audio0p
			updateAudio(0)
		1:
			$Buttons/audio.texture_normal = audio1
			$Buttons/audio.texture_pressed = audio1p
			updateAudio(0.25)
		2:
			$Buttons/audio.texture_normal = audio2
			$Buttons/audio.texture_pressed = audio2p
			updateAudio(0.5)
		3:
			$Buttons/audio.texture_normal = audio3
			$Buttons/audio.texture_pressed = audio3p
			updateAudio(0.75)
			
func updateAudio(var setting):
	AudioServer.set_bus_volume_db(
		bus_index,
		linear2db(setting)
	)

func _on_prev_pressed():
	Global.cur_lvl -= 1
	_on_restart_pressed()

func _on_next_pressed():
	Global.cur_lvl += 1
	_on_restart_pressed()
	
func disable_prev():
	$Buttons/prev.disabled = true
	$Buttons/prev.modulate.a = 0.5
	
func enable_prev():
	$Buttons/prev.disabled = false
	$Buttons/prev.modulate.a = 1
	
func disable_next():
	$Buttons/next.disabled = true
	$Buttons/next.modulate.a = 0.5
	
func enable_next():
	$Buttons/next.disabled = false
	$Buttons/next.modulate.a = 1
