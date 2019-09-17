extends Node2D

var grid = []
const ROWS = 10
const HEIGHT = 900
var h = HEIGHT / ROWS
var b = h*2.0/sqrt(3)
const OFFSET = Vector2(20, 20)

const Point = preload('res://Point.tscn')

onready var snake = $Field/Snake

func _ready():
	var row
	var this_grid = []
	var grid = []
	for i in ROWS:
		this_grid.append([])
		grid.append([])
		
		var white = ROWS-i-1
		var n_points = i*2+1
		var r_points = 0
		for j in ROWS*2-1:
			
			if j<white:
				this_grid[i].append("-")
				grid[i].append(null)
			elif j>=white and j<n_points+white:
				if r_points% 2:
					this_grid[i].append("+")
					grid[i].append(null)
					r_points+=1
					continue
				var point = Point.instance()
				point.position = OFFSET*Vector2(j, i)
				grid[i].append(point)
				$Field/Grid.add_child(point)
				this_grid[i].append("x")
				r_points += 1
			else:
				this_grid[i].append("-")
				grid[i].append(null)
	for i in ROWS:
		print(this_grid[i])


	# set up the snake
	#snake.world = self
	#update_snake_position()
	
	# movement
	#$Timer.connect('timeout', self, '_on_tick')
	for i in ROWS:
		print(grid[i])
	
func _on_tick():
	snake.cell += snake.get_direction()
	update_snake_position()
	
func update_snake_position():
	var i = int(snake.cell[0])
	var j = int(snake.cell[1])
	var wrapping = false
	
	if i >= ROWS:
		# wrap bottom -> left
		wrapping = true
		snake.cell[0] = j-1
		snake.cell[1] = 0
		if snake.dir == 2:
			snake.rotate_direction()
	elif j >= len(grid[i]):
		# wrap right -> bottom
		wrapping = true
		snake.cell[0] = ROWS-1
		snake.cell[1] = i
		if snake.dir == 0:
			snake.rotate_direction()
	elif j <= 0:
		# wrap left -> right
		wrapping = true
		snake.cell[1] = len(grid[i])-1
		if snake.dir == 4:
			snake.rotate_direction()
	
	snake.move(wrapping)
	
#func ij2xy(ij):
#	return Vector2(ij[1]*b-ij[0]*b/2.0, ij[0]*h)
	