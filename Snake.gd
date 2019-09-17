extends Node2D

var cell = Vector2(0, 0)
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
	if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right") and not dir==2:
		dir = 5
	elif Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left") and not dir==5:
		dir = 2
	elif Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_left") and not dir==1:
		dir = 4
	elif Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_right") and not dir==4:
		dir = 1
	elif Input.is_action_pressed("ui_left") and not dir==0:
		dir = 3 
	elif Input.is_action_pressed("ui_right") and not dir == 3:
		dir = 0
			
func rotate_direction():
	dir = (dir + 4) % len(directions)
	
func get_direction():
	return directions[dir]
	
func move(wrapping = false):
	$Head.position = world.ij2xy(cell)
	
	if not wrapping:
		tail.append(cell)
		if len(tail) > size:
			tail.pop_front()
			
		for segment in $Tail.get_children():
			segment.free()
			
		for i in len(tail)-1:
			var line = Line2D.new()
			line.default_color = Color(1,1,1,1)
			$Tail.add_child(line)
			line.points = PoolVector2Array([world.ij2xy(tail[i]), world.ij2xy(tail[i+1])])
			