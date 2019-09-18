extends Node2D

var cell = Vector2(20, 5)
var dir = 0

var size = 10
var tail = []

var world

var directions = [
	Vector2(0, 1), # 0 right
	Vector2(1, 1), # 1 down right
	Vector2(1, 0), # 2 down left
	Vector2(0, -1), # 3 left
	Vector2(-1, -1), # 4 up left
	Vector2(-1, 0) # 5 up right
]

func _input(event):
	if Input.is_action_pressed("ui_right") and not(Input.is_action_pressed("ui_left")):
		if Input.is_action_pressed("ui_up"):
			print('Up Right')
			dir = 5
		elif Input.is_action_pressed("ui_down"):
			print('Down Right')
			dir = 1
		else:
			print('Right')
			dir = 0
	elif not(Input.is_action_pressed("ui_right")) and Input.is_action_pressed("ui_left"):
		if Input.is_action_pressed("ui_up"):
			print('Up Left')
			dir = 4
		elif Input.is_action_pressed("ui_down"):
			print('Down Left')
			dir = 2
		else:
			print('Left')
			dir = 3
			
func rotate_direction():
	dir = (dir + 4) % len(directions)
	
func get_direction():
	return directions[dir]
	
func move(wrapping = false):
	$Head.position = world.ij2xy(cell)
	

	tail.append(cell)
	if len(tail) > size:
		tail.pop_front()
		
	for segment in $Tail.get_children():
		segment.free()
	
	for i in len(tail)-1:
		var line = Line2D.new()
		line.default_color = Color(1,1,1,1)
		$Tail.add_child(line)
		
		if abs(tail[i+1].x - tail[i].x) > 1 or abs(tail[i].y - tail[i+1].y) > 1:
			print(tail[i], " vs ", tail[i+1])
		else:
			line.points = PoolVector2Array([world.ij2xy(tail[i]), world.ij2xy(tail[i+1])])