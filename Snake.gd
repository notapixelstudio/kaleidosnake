extends Node2D

var cell = Vector2(20, 5)
var dir = 0

var size = 5 setget growing
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

onready var sound_dead = $SoundDead
	
signal grown
func growing(new_value):
	size = new_value
	emit_signal("grown", get_tail_size())
	
func _input(event):
	if Input.is_action_just_pressed("ui_right") or event.is_action_released("ui_right"):
		if Input.is_action_pressed("ui_up"):
			#print('Up Right')
			if not dir == DIR.DOWNLEFT:
				dir = DIR.UPRIGHT
		elif Input.is_action_just_pressed("ui_down"):
			#print('Down Right')
			if not dir == DIR.UPLEFT:
				dir = DIR.DOWNRIGHT
		else:
			#print('Right')
			if not dir == DIR.LEFT:
				dir = DIR.RIGHT
				
	if Input.is_action_just_pressed("ui_up"):
		if Input.is_action_pressed("ui_right"):
			#print('Up Right')
			if not dir == DIR.DOWNLEFT:
				dir = DIR.UPRIGHT
		elif Input.is_action_pressed("ui_left"):
			#print('Up Left')
			if not dir == DIR.DOWNRIGHT:
				dir = DIR.UPLEFT
				
	if event.is_action_released("ui_up") or event.is_action_released("ui_down"):
		if Input.is_action_pressed("ui_right"):
			#print('Right')
			if not dir == DIR.LEFT:
				dir = DIR.RIGHT
		elif Input.is_action_pressed("ui_left"):
			#print('Left')
			if not dir == DIR.RIGHT:
				dir = DIR.LEFT

	if Input.is_action_just_pressed("ui_left") or event.is_action_released("ui_left"):
		if Input.is_action_pressed("ui_up"):
			#print('Up Left')
			if not dir == DIR.DOWNRIGHT:
				dir = DIR.UPLEFT
		elif Input.is_action_pressed("ui_down"):
			#print('Down Left')
			if not dir == DIR.UPRIGHT:
				dir = DIR.DOWNLEFT
		else:
			#print('Left')
			if not dir == DIR.RIGHT:
				dir = DIR.LEFT
				
	if Input.is_action_just_pressed("ui_down"):
		if Input.is_action_pressed("ui_right"):
			if not dir == DIR.UPLEFT:
				dir = DIR.DOWNRIGHT
		elif Input.is_action_pressed("ui_left"):
			#print('Up Left')
			if not dir == DIR.UPRIGHT:
				dir = DIR.DOWNLEFT
				
			
	"""
	if Input.is_action_pressed("ui_right") and not(Input.is_action_pressed("ui_left")):
		if Input.is_action_pressed("ui_up"):
			#print('Up Right')
			if not dir == DIR.DOWNLEFT:
				dir = DIR.UPRIGHT
		elif Input.is_action_pressed("ui_down"):
			#print('Down Right')
			if not dir == DIR.UPLEFT:
				dir = DIR.DOWNRIGHT
		else:
			#print('Right')
			if not dir == DIR.LEFT:
				dir = DIR.RIGHT
	elif not(Input.is_action_pressed("ui_right")) and Input.is_action_pressed("ui_left"):
		if Input.is_action_pressed("ui_up"):
			#print('Up Left')
			if not dir == DIR.DOWNRIGHT:
				dir = DIR.UPLEFT
		elif Input.is_action_pressed("ui_down"):
			#print('Down Left')
			if not dir == DIR.UPRIGHT:
				dir = DIR.DOWNLEFT
		else:
			#print('Left')
			if not dir == DIR.RIGHT:
				dir = DIR.LEFT
		"""
func rotate_direction():
	dir = (dir + 4) % len(directions)
	
func get_direction():
	return directions[dir]
	
func move(missed_cell):
	$Head.position = world.ij2xy(cell)
	
	if missed_cell:
		warp(missed_cell, cell)
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
	
	var where = world.check_cell(cell)
	if where.type == "snake":
		die()
	elif where.type == "food":
		eat(cell)
	world.add_cell(cell, "snake")

onready var sound_eat = $SoundEat
func eat(food_cell):
	sound_eat.play()
	self.size+=1
	world.eat_food(food_cell)
	
signal stop
func die():
	sound_dead.play()
	emit_signal("stop")
	$AnimationPlayer.play("die")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("dead")

func get_tail_size():
	return size

signal warped
func warp(from, to):
	$SoundWarp.play()
	$WarpedHead.visible = true
	$Tween.interpolate_property($WarpedHead, "position", world.ij2xy(from), world.ij2xy(to), 0.6, Tween.EASE_OUT_IN, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$WarpedHead.visible = false
	emit_signal("warped")
	