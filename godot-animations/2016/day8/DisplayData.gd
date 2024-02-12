extends Node

@export var grid_size: Vector2i

var data: Array

signal changed(data)

func _ready():
	data = []
	for i in grid_size[1]:
		var row = []
		row.resize(grid_size[0])
		row.fill(false)
		data.append(row)
		
	emit_signal("changed", data)

func fill(rect):
	for col in rect[0]:
		for row in rect[1]:
			data[row][col] = true
	
	emit_signal("changed", data)
	
func rotate_row(row_i):
	var row = data[row_i]
	var cell = row.pop_back()
	row.push_front(cell)
	
	emit_signal("changed", data)
	
func rotate_col(col_i):
	var prev_val = data[-1][col_i]
	for i in range(grid_size[1]):
		var new_prev_val = data[i][col_i]
		data[i][col_i] = prev_val
		prev_val = new_prev_val
	
	emit_signal("changed", data)
