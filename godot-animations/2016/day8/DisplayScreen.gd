extends Panel

var data = [[false]]

func _draw():
	var pixel_size = Vector2i(9, 9)
	
	var row = 0
	for data_row in data:
		var col = 0
		
		for pixel in data_row:
			if pixel:
				draw_rect(Rect2(Vector2(col*10 + 5, row * 10 + 5), pixel_size), Color.BLACK)
			col += 1
			
		row += 1

func _on_display_data_changed(data):
	self.data = data
	queue_redraw()
