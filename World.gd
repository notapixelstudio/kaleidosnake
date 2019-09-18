extends Node2D

var grid = []
const ROWS = 40
const HEIGHT = 900
var h = HEIGHT / ROWS
var b = h*2.0/sqrt(3)

const Point = preload('res://Point.tscn')

onready var snake = $Field/Snake

# Called when the node enters the scene tree for the first time.
func _ready():
	var row
	
	for i in ROWS:
		row = []
		for j in i+1:
			var coords = ij2xy(Vector2(i, j))
			var point = {
				'i': i,
				'j': j,
				'node': Point.instance()
			}
			point['node'].position = Vector2(coords.x, coords.y)
			row.append(point)
			$Field/Grid.add_child(point['node'])
		grid.append(row)
		
	# set up the snake
	snake.world = self
	update_snake_position()
	
	# movement
	$Timer.connect('timeout', self, '_on_tick')
	
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
		snake.cell[0] = j
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
	elif j < 0:
		# wrap left -> right
		wrapping = true
		snake.cell[1] = len(grid[i])-1
		if snake.dir == 4:
			snake.rotate_direction()
	
	snake.move(wrapping)
	
func ij2xy(ij):
	return Vector2(ij[1]*b-ij[0]*b/2.0, ij[0]*h)
	