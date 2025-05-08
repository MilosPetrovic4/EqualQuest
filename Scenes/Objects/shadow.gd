extends Node2D

var frame_index = -1 

func setFrame(var char_):
	match char_:
		"0":
			frame_index = 0
		"1":
			frame_index = 1
		"2":
			frame_index = 2
		"+":
			frame_index = 3
		"=":
			frame_index = 4
		_:
			print("Unknown character:", char_)
			
	if frame_index >= 0:
		$sprite.animation = "red"
		$sprite.frame = frame_index
