extends Node


var facing = Vector2.UP
var current_point = Vector2.ZERO
var point_data = []

var steps = []

var steps_per_second = 100

func _on_input_available(data):
	for step in data.split(", "):
		var turn = step[0]
		var distance = int(step.right(-1))
		steps.append([turn, distance])

	add_point(current_point)
	
	await part1()
	part2()
	
func add_point(point):
	var point_i = Vector2i(point.round())
	point_data.append(point_i)
	$CityGrid/Line2D.add_point(point)

func part1():

	for step in steps:
		var turn = step[0]
		var distance = step[1]
		
		if turn == "R":
			facing = facing.rotated(PI/2).round()
		else:
			facing = facing.rotated(-PI/2).round()
		
		current_point += facing * distance
		add_point(current_point)

		await get_tree().create_timer(1.0 / steps_per_second).timeout
	
	var end_point = point_data[-1]
	var distance = abs(end_point.x) + abs(end_point.y)
	
	$Part1Label.text += str(distance)
	$CityGrid/Part1Point.position = Vector2(end_point)
	$CityGrid/Part1Point.show()
	
func part2():
	var revisit = null
	$CityGrid/Part2Highlight.show()
	
	for seg_i in range(2, point_data.size()):
		var seg_start = Vector2(point_data[seg_i])
		var seg_end = Vector2(point_data[seg_i+1])
		
		$CityGrid/Part2Highlight.clear_points()
		$CityGrid/Part2Highlight.add_point(seg_start)
		$CityGrid/Part2Highlight.add_point(seg_end)
		await get_tree().create_timer(3.0 / steps_per_second).timeout
				
		for prev_i in range(0, seg_i-1):
			var prev_start = Vector2(point_data[prev_i])
			var prev_end = Vector2(point_data[prev_i+1])
			
			revisit = Geometry2D.segment_intersects_segment(prev_start, prev_end, seg_start, seg_end)
			
			if revisit != null:
				break
				
		if revisit != null:
			break
			
	$CityGrid/Part2Point.position = revisit
	$CityGrid/Part2Point.show()
	
	revisit = Vector2i(revisit.round())
	var distance = abs(revisit.x) + abs(revisit.y)
	$Part2Label.text += str(distance) 
