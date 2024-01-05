extends CanvasLayer

var triangles_per_second = 200
var triangle_scale_factor = 1.0/10

func _on_input_available(data):
	Engine.physics_ticks_per_second = 60
	
	var lines = data.split("\n")
	
	await part1(lines)
	
	# reset triangles
	await get_tree().create_timer(3).timeout
	get_tree().call_group("triangles", "queue_free")

	part2(lines)
	
func part1(lines):
	var count = 0
	
	for line in lines:
		var nums = line.split_floats(" ", false)
		
		if spawn_triangle(nums):
			count += 1
			$Part1Label.text = "Part 1: %d" % count
		
		await get_tree().create_timer(1.0 / triangles_per_second).timeout

func part2(lines):
	var count = 0
	
	for i in range(0, lines.size(), 3):
		var row1 = lines[i].split_floats(" ", false)
		var row2 = lines[i+1].split_floats(" ", false)
		var row3 = lines[i+2].split_floats(" ", false)
		
		if spawn_triangle([row1[0], row2[0], row3[0]]):
			count += 1
		if spawn_triangle([row1[1], row2[1], row3[1]]):
			count += 1
		if spawn_triangle([row1[2], row2[2], row3[2]]):
			count += 1
		
		$Part2Label.text = "Part 2: %d" % count
		
		await get_tree().create_timer(1.0 / triangles_per_second).timeout

func spawn_triangle(lengths):
	lengths.sort()
	
	if lengths[0] + lengths[1] <= lengths[2]:
		return false
	
	for i in range(lengths.size()):
		lengths[i] *= triangle_scale_factor
	
	var triangle = preload("res://2016/day3/rigid_triangle.tscn").instantiate()
	triangle.add_to_group("triangles")
	triangle.lengths = lengths
	
	var spawn_point = $TrianglePath/TriangleSpawnPoint
	spawn_point.progress_ratio = randf()
	triangle.position = spawn_point.position
	triangle.rotation = randf_range(0, PI)
	
	# Add as a child of TriangleContainer, so the triangles are rendered behind scene labels
	$TriangleContainer.add_child.call_deferred(triangle)
	
	return true
