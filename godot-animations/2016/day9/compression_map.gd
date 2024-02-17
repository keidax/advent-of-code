extends Control

var text_length = 1024
var letter_size = Vector2(1, 4)
var space_between_rows = 20

class TextDecoration:
	var start : int
	var end : int
	var color : Color
	
var decorations = [[]]

func decorate_text(start, end, color, level = 0):
	while decorations.size() <= level:
		decorations.append([])
		
	var deco = TextDecoration.new()
	deco.start = start
	deco.end = end
	deco.color = color
	decorations[level].append(deco)
	queue_redraw()
	
func clear():
	decorations = [[]]
	queue_redraw()

func _draw():
	var letters_per_row = int(size.x / letter_size.x)
	var row_pos = Vector2(0, 0)
	
	for row_start in range(0, text_length, letters_per_row):
		var row_end = min(text_length, row_start+letters_per_row)
		draw_row(row_pos, row_start, row_end)
		row_pos.y += letter_size.y + space_between_rows

func draw_row(row_pos, row_start, row_end):
	var row_size = row_end - row_start
	var base_rect = Rect2(row_pos, Vector2(letter_size.x * row_size, letter_size.y))
	draw_rect(base_rect, Color.DIM_GRAY)
	
	for level in range(decorations.size()):
		decorate_level(row_pos + Vector2(0, 2)*level, row_start, row_end, level)
	
func decorate_level(row_pos, row_start, row_end, level):
	var i = find_first_deco_index(row_start, level)
	
	while i < decorations[level].size():
		var deco = decorations[level][i]
		if deco.start >= row_end:
			break
		
		var start = max(deco.start, row_start)
		var end = min(deco.end, row_end)
		
		var deco_start = Vector2((start - row_start) * letter_size.x, 0)
		var deco_size = Vector2((end - start) * letter_size.x, letter_size.y)
		
		var deco_rect = Rect2(row_pos + deco_start, deco_size)
		draw_rect(deco_rect, deco.color)
		i += 1
	
func find_first_deco_index(start, level):
	var decos = decorations[level]
	
	var comparison = func(val, target):
		return val.start < target
	var index = decos.bsearch_custom(start, comparison)
	if index > 0 && decos[index - 1].end >= start:
		index -= 1
		
	return index
