extends CanvasLayer

var moves_per_second = 60

func _on_input_available(data):
	var lines = data.split("\n")
	process_draw_instructions(lines)

func process_draw_instructions(lines):
	var rect_regex = RegEx.new()
	var row_regex = RegEx.new()
	var col_regex = RegEx.new()
	rect_regex.compile("rect (\\d+)x(\\d+)")
	row_regex.compile("rotate row y=(\\d+) by (\\d+)")
	col_regex.compile("rotate column x=(\\d+) by (\\d+)")
	
	for line in lines:
		var result = rect_regex.search(line)
		if result:
			var width = result.get_string(1)
			var height = result.get_string(2)
			var rect = Vector2i(int(width), int(height))
			$DisplayData.fill(rect)
			await get_tree().create_timer(1.0/moves_per_second).timeout
			continue
			
		result = row_regex.search(line)
		if result:
			var row = int(result.get_string(1))
			var shift = int(result.get_string(2))
			
			for i in shift:
				$DisplayData.rotate_row(row)
				await get_tree().create_timer(1.0/moves_per_second).timeout
			
			continue
			
		result = col_regex.search(line)
		if result:
			var col = int(result.get_string(1))
			var shift = int(result.get_string(2))
			
			for i in shift:
				$DisplayData.rotate_col(col)
				await get_tree().create_timer(1.0/moves_per_second).timeout
			
			continue

func _on_display_data_changed(data):
	var pixel_count = 0
	for row in data:
		for pixel in row:
			if pixel:
				pixel_count += 1
	
	$Part1Label.text = "Part 1: %d" % pixel_count
