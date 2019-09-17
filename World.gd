extends Node2D

var grid = []
const ROWS = 40
const HEIGHT = 900
var h = HEIGHT / ROWS
var b = h*2.0/sqrt(3)
const OFFSET = Vector2(10, 10)
var arena = {}
var side_a = []
var side_b = []
var side_c = []

const Point = preload('res://Point.tscn')

onready var snake = $Field/Snake


func _ready():
	var row
	var this_grid = []
	
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
					grid[i].append({"empty": true})
					r_points+=1
					continue
				var point = Point.instance()
				point.position = OFFSET*Vector2(j, i)
				point.name = str(i)+"_"+str(j)
				point.grid_index = Vector2(i, j)
				grid[i].append(point)
				$Field/Grid.add_child(point)
				this_grid[i].append("x")
				r_points += 1
			else:
				this_grid[i].append("-")
				grid[i].append(null)

	# set up the snake
	snake.world = self
	#update_snake_position()
	
	# movement
	$Timer.connect('timeout', self, '_on_tick')
	for i in ROWS:
		for j in len(grid[i]):
			if grid[i][j] and not i in arena:
				arena[i] = {"start": grid[i][j], "end":grid[i][j]}
				break
		for j in range(ROWS*2-2, 0, -1):
			if grid[i][j]:
				arena[i]["end"] = grid[i][j]
				break
	# print(arena)
	for a in arena:
		# fill side_a -> right
		side_a.append(arena[a]["end"])
		side_b.append(arena[a]["start"])
		for k in arena[a]:
			print(a, ": ", k, arena[a][k].name)
	
	# reverse side_b for reference
	side_b.invert()
	for node in grid[ROWS-1]:
		if not node == null and not "empty" in node:
			side_c.append(node)
	print("LATO DESTRO")
	for node in side_a:
		print(node.name)
	print("LATO SINISTRO")
	for node in side_b:
		print(node.name)
	print("LATO GIU")
	for node in side_c:
		print(node.name)

func from_index_to_point(x, y):
	return grid[x][y]
	
func _on_tick():
	snake.cell += snake.get_direction()
	update_snake_position()
	
func update_snake_position():
	var point = from_index_to_point(snake.cell.x, snake.cell.y)
	var i = int(snake.cell.x)
	var j = int(snake.cell.y)
	var wrapping = false
	
	if point in side_a and not snake.dir == 1 and not snake.dir == 4:
		var index_point = side_a.find(point)
		# rigt -> bottom
		# we will wrap in side_c
		snake.cell = side_c[index_point].grid_index
		if snake.dir == 0:
			snake.rotate_direction()
	elif point in side_b and not snake.dir == 2 and not snake.dir == 5:
		var index_point = side_b.find(point)
		# we will wrap in side_a
		snake.cell = side_a[len(side_a)-1-index_point].grid_index
		if snake.dir == 4:
			snake.rotate_direction()
	elif point in side_c and not snake.dir == 0 and not snake.dir == 3:
		var index_point = side_c.find(point)
		# we will wrap in side_a
		snake.cell = side_b[index_point].grid_index
		if snake.dir == 2:
			snake.rotate_direction()
	
	if snake.try_move(wrapping):
		snake.move(wrapping)
	
#func ij2xy(ij):
#	return Vector2(ij[1]*b-ij[0]*b/2.0, ij[0]*h)
	