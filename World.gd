extends Node

var grid = []
const ROWS = 40
const HEIGHT = 700
var h = HEIGHT / ROWS
var b = h*2.0/sqrt(3)

export var grid_color : Color = Color.gray
export var FoodScene : PackedScene

onready var snake = $MainView/Viewport/Field/Snake
onready var gameover = $CanvasLayer/GameOver

onready var main_view = $MainView/Viewport
onready var view2 = $View2/Viewport
onready var view3 = $View3/Viewport
onready var view4 = $View4/Viewport

onready var timer = $Timer

onready var hud = $CanvasLayer/HUD

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	snake.connect("stop", self, "stop")
	snake.connect("dead", self, "_on_gameover")
	snake.connect("grown", self, "snake_bigger")
	var row
	
	for i in ROWS:
		row = []
		for j in i+1:
			var coords = ij2xy(Vector2(i, j))
			var point = {
				'i': i,
				'j': j,
				'position': Vector2(coords.x, coords.y),
				"type": "empty",
				"object": null
			}
			point.visible = false
			row.append(point)
			
		grid.append(row)
		
	# set up the first food
	add_food()
	
	# set up the snake
	snake.world = self
	update_snake_position()
	
	# movement
	$Timer.connect('timeout', self, '_on_tick')
	
	view2.world_2d = main_view.world_2d
	view3.world_2d = main_view.world_2d
	view4.world_2d = main_view.world_2d
	
	# horizantal line
	for row in grid:
		var line = Line2D.new()
		$MainView/Viewport/Field/Grid.add_child(line)
		line.width = 3
		line.name = "Horizontal"
		line.default_color = grid_color
		line.light_mask |= 1 << 1
		for point in row:
			line.add_point(point.position)
	
	# down right line
	for i in len(grid)-1:
		var line = Line2D.new()
		$MainView/Viewport/Field/Grid.add_child(line)
		line.width = 3
		line.name = "DownRight"
		line.default_color = grid_color
		line.light_mask |= 1 << 1
		for j in range(i, len(grid)):
			line.add_point(grid[j][len(grid[j])-1-i].position)
			
		#print(line.points)
	
	# down left line
	for i in len(grid)-1:
		var line = Line2D.new()
		$MainView/Viewport/Field/Grid.add_child(line)
		line.width = 3
		line.name = "DownLeft"
		line.default_color = grid_color
		line.light_mask |= 1 << 1
		for j in range(i, len(grid)):
			
			line.add_point(grid[j][i].position)
var ticks = 0

func _on_tick():
	if wrapping:
		$Timer.paused = true
		yield(get_tree().create_timer(0.2), "timeout")
		$Timer.paused = false
	snake.cell += snake.get_direction()
	
	update_snake_position()
	
	ticks += 1
	if not ticks % 20:
		print("less time ", str($Timer.wait_time))
		$Timer.wait_time -= 0.001

var wrapping : bool  = false

func eat_food(removed_cell):
	if grid[removed_cell.x][removed_cell.y].object:
		grid[removed_cell.x][removed_cell.y].object.queue_free()
		grid[removed_cell.x][removed_cell.y].object = null
		add_food()
	remove_cell(removed_cell)
func remove_cell(removed_cell):
	grid[removed_cell.x][removed_cell.y].type = "empty"
	
func add_cell(cell, what):
	grid[cell.x][cell.y].type = what
	
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

func check_cell(cell):
	return grid[cell.x][cell.y]

func ij2xy(ij):
	return Vector2(ij[1]*b-ij[0]*b/2.0, ij[0]*h)

func stop():
	timer.stop()

func _on_gameover():
	gameover.start()
	
func snake_bigger(score):
	hud.update_score(score)

	
func add_food():
	yield(get_tree().create_timer(1), "timeout")
	var food = FoodScene.instance()
	var rand_row = (randi()+1) % (len(grid)-1)
	while rand_row == 0:
		rand_row = (randi()+1) % (len(grid)-1)
	var rand_col = (randi()+1) % (len(grid[rand_row])-1)
	while(grid[rand_row][rand_col].type != "empty") or rand_col == 0:
		print("That unlucky, ", str(rand_row), " ", str(rand_col))
		rand_row = randi() % (len(grid)-1)
		rand_col = randi()%(len(grid[rand_row])-1)
	var rand_pos = Vector2(rand_row, rand_col)
	food.position = ij2xy(rand_pos)
	grid[rand_row][rand_col].type = "food"
	grid[rand_row][rand_col].object = food
	$MainView/Viewport/Field.add_child(food)
	