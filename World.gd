extends Node

var grid = []
const ROWS = 40
const HEIGHT = 700
var h = HEIGHT / ROWS
var b = h*2.0/sqrt(3)

const Point = preload('res://Point.tscn')

onready var snake = $MainView/Viewport/Field/Snake

onready var main_view = $MainView/Viewport
onready var view2 = $View2/Viewport
onready var view3 = $View3/Viewport
onready var view4 = $View4/Viewport

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
			$MainView/Viewport/Field/Grid.add_child(point['node'])
		grid.append(row)
		
	# set up the snake
	snake.world = self
	update_snake_position()
	
	# movement
	$Timer.connect('timeout', self, '_on_tick')
	
	view2.world_2d = main_view.world_2d
	view3.world_2d = main_view.world_2d
	view4.world_2d = main_view.world_2d
	
var ticks = 0

func _on_tick():
	if wrapping:
		$Timer.paused = true
		yield(get_tree().create_timer(0.2), "timeout")
		$Timer.paused = false
	snake.cell += snake.get_direction()
	
	update_snake_position()
	
		
	ticks += 1
	if ticks % 4 == 0:
		snake.size += 1

var wrapping : bool  = false
func update_snake_position():
	var i = int(snake.cell[0])
	var j = int(snake.cell[1])
	wrapping = false
	var missed_cell = snake.cell
	if i >= ROWS-1:
		# wrap bottom -> left
		wrapping = true
		snake.cell[0] = j
		snake.cell[1] = 0
		if snake.dir == 2:
			snake.rotate_direction()
	elif j >= len(grid[i])-1:
		# wrap right -> bottom
		wrapping = true
		snake.cell[0] = ROWS-1
		snake.cell[1] = ROWS-1-i
		if snake.dir == 0:
			snake.rotate_direction()
	elif j <= 0:
		# wrap left -> right
		wrapping = true
		snake.cell[0] = ROWS-i-1
		snake.cell[1] = len(grid[ROWS-i-1])-1
		if snake.dir == 4:
			snake.rotate_direction()
	if not wrapping:
		missed_cell = null
	snake.move(missed_cell)
	
func ij2xy(ij):
	return Vector2(ij[1]*b-ij[0]*b/2.0, ij[0]*h)
	