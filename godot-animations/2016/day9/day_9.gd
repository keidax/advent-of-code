extends CanvasLayer

var decorations_per_second = 120
var text_marker = RegEx.new()
var compressed_text_gradient = Gradient.new()

var part1_total = 0:
	set(value):
		if value != 0:
			$Part1Label.text = "Part 1: %d" % value
		part1_total = value
		
var part2_total = 0:
	set(value):
		if value != 0:
			$Part2Label.text = "Part 2: %d" % value
		part2_total = value
	

func _init():
	text_marker.compile("\\((\\d+)x(\\d+)\\)")

	compressed_text_gradient.colors = PackedColorArray([Color.LAWN_GREEN, Color.ORANGE_RED])
	compressed_text_gradient.add_point(0.3, Color.LIGHT_SEA_GREEN)
	compressed_text_gradient.add_point(0.6, Color.REBECCA_PURPLE)

func _on_input_available(data):
	var compressed_text = data.strip_edges()
	$CompressionMap.text_length = compressed_text.length()
	await decompress_part1(compressed_text)
	
	await get_tree().create_timer(2).timeout
	$CompressionMap.clear()
	
	await decompress_part2(compressed_text)

func decompress_part1(text):
	var search_start = 0
	
	var result = text_marker.search(text, search_start)
	while result:
		var match_start = result.get_start()
		if match_start > search_start:
			part1_total += match_start - search_start
			$CompressionMap.decorate_text(search_start, match_start, Color.LAWN_GREEN)
			await get_tree().create_timer(10.0/decorations_per_second).timeout
		
		var length = int(result.get_string(1))
		var repetitions = int(result.get_string(2))
		part1_total += length * repetitions
		$CompressionMap.decorate_text(result.get_start(), result.get_end(), Color.WHITE)
		await get_tree().create_timer(10.0/decorations_per_second).timeout
		$CompressionMap.decorate_text(result.get_end(), result.get_end() + length, Color.MEDIUM_PURPLE)
		await get_tree().create_timer(10.0/decorations_per_second).timeout
		
		search_start = result.get_end() + length
		result = text_marker.search(text, search_start)
	
	if text.length() > search_start:
		part1_total += text.length() - search_start
		$CompressionMap.decorate_text(search_start, text.length(), Color.LAWN_GREEN)
		await get_tree().create_timer(10.0/decorations_per_second).timeout
	
func decompress_part2(text):
	await decompress_recursive(text, 0, text.length(), 0, 1)
	
func color_at_level(level):
	var f = level / 8.0
	return compressed_text_gradient.sample(f)
	
func decompress_recursive(text, start, end, level, multiplier):
	var search_start = start
	
	var result = text_marker.search(text, search_start, end)
	while result:
		var match_start = result.get_start()
		if match_start > search_start:
			part2_total += (match_start - search_start) * multiplier
			$CompressionMap.decorate_text(search_start, match_start, color_at_level(level), level)
			await get_tree().create_timer(1.0/decorations_per_second).timeout
		
		var length = int(result.get_string(1))
		var repetitions = int(result.get_string(2))
		$CompressionMap.decorate_text(result.get_start(), result.get_end(), Color.WHITE, level)
		#await get_tree().create_timer(1.0/decorations_per_second).timeout
		
		$CompressionMap.decorate_text(result.get_end(), result.get_end()+length, color_at_level(level), level)
		
		await decompress_recursive(text, result.get_end(), result.get_end() + length, level + 1, multiplier * repetitions)
		#await get_tree().create_timer(1.0/decorations_per_second).timeout
		
		search_start = result.get_end() + length
		result = text_marker.search(text, search_start, end)
	
	if end > search_start:
		part2_total += (end - search_start) * multiplier
		$CompressionMap.decorate_text(search_start, end, color_at_level(level), level)
		await get_tree().create_timer(1.0/decorations_per_second).timeout
