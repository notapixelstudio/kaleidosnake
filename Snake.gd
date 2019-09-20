extends Node2D

var cell = Vector2(20, 5)
var dir = 0

var size = 10 setget growing
var tail = []

var world
signal dead
enum DIR {RIGHT, DOWNRIGHT, DOWNLEFT, LEFT, UPLEFT, UPRIGHT}

var directions = [
	Vector2(0, 1), # 0 right
	Vector2(1, 1), # 1 down right
	Vector2(1, 0), # 2 down left
	Vector2(0, -1), # 3 left
	Vector2(-1, -1), # 4 up left
	Vector2(-1, 0) # 5 up right
]

signal grown
func growing(new_value):
	size = new_value
	emit_signal("grown", get_tail_size())
	
func _input(event):
	if Input.is_action_pressed("ui_right") and not(Input.is_action_pressed("ui_left")):
		if Input.is_action_pressed("ui_up"):
			print('Up Right')
			if not dir == 2:
				dir = 5
		elif Input.is_action_pressed("ui_down"):
			print('Down Right')
			if not dir == 4:
				dir = 1
		else:
			print('Right')
			if not dir == 3:
				dir = 0
	elif not(Input.is_action_pressed("ui_right")) and Input.is_action_pressed("ui_left"):
		if Input.is_action_pressed("ui_up"):
			print('Up Left')
			if not dir == 1:
				dir = 4
		elif Input.is_action_pressed("ui_down"):
			print('Down Left')
			if not dir == 5:
				dir = 2
		else:
			print('Left')
			if not dir == 0:
				dir = 3
			
func rotate_direction():
	dir = (dir + 4) % len(directions)
	
func get_direction():
	return directions[dir]
	
func move(missed_cell):
	$Head.position = world.ij2xy(cell)
	
	if missed_cell:
		tail.append(missed_cell)
		
	tail.append(cell)
	if len(tail) > size:
		var to_be_removed = tail.pop_front()
		world.remove_cell(to_be_removed)
		
	for segment in $Tail.get_children():
		segment.free()
	
	for i in len(tail)-1:
		
		var line = Line2D.new()
		line.default_color = Color(1,1,1,1)
		$Tail.add_child(line)
		
		if abs(tail[i+1].x - tail[i].x) > 1 or abs(tail[i].y - tail[i+1].y) > 1:
			pass
		else:
			line.points = PoolVector2Array([world.ij2xy(tail[i]), world.ij2xy(tail[i+1])])
	
	if world.check_cell(cell).type == "snake":
		die()
	world.add_cell(cell, "snake")

signal stop
func die():
	emit_signal("stop")
	$AnimationPlayer.play("die")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("dead")

func get_tail_size():
	return size