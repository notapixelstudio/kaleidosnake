extends Node2D

var cell = Vector2(5, 34)
var dir = 0

var size = 10
var tail = []

var world

var directions = [
	Vector2(0, 2), # 0 right
	Vector2(1, 1), # 1 down right
	Vector2(1, -1), # 2 down left
	Vector2(0, -2), # 3 left
	Vector2(-1, -1), # 4 up left
	Vector2(-1, 0) # 5 up right
]

func _input(event):
	if event.is_action_pressed("ui_up") and event.is_action_pressed("ui_right") and not dir==2:
		dir = 5
	elif event.is_action_pressed("ui_down") and event.is_action_pressed("ui_left") and not dir==5:
		dir = 2
	elif event.is_action_pressed("ui_up") and event.is_action_pressed("ui_left") and not dir==1:
		dir = 4
	elif event.is_action_pressed("ui_down") and event.is_action_pressed("ui_right") and not dir==4:
		dir = 1
	elif event.is_action_pressed("ui_left") and not dir==0:
		dir = 3 
	elif event.is_action_pressed("ui_right") and not dir == 3:
		dir = 0
			
func rotate_direction():
	dir = (dir + 4) % len(directions)
	
func get_direction():
	return directions[dir]

func try_move(wrapping = false):
	return not world.grid[cell.x][cell.y] == null and not "empty" in world.grid[cell.x][cell.y]
	
func move(wrapping = false):
	$Head.position = world.grid[cell.x][cell.y].position
	