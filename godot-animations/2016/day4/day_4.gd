extends CanvasLayer

var rooms_per_second = 1.8
var speed_factor = 2.0

func _on_input_available(data):
	var lines = data.split("\n")
	await part1(lines)
	await get_tree().create_timer(1.0).timeout
	part2()

func part1(lines):
	for l in lines:
		add_room(l)
		await get_tree().create_timer(1.0 / (rooms_per_second * speed_factor)).timeout

func add_room(room_text):
	var room = preload("res://2016/day4/room_name.tscn").instantiate()
	room.add_to_group("rooms")
	room.text = room_text
	room.position = Vector2(20, 730)
	room.target_time = 2.0 / speed_factor
	
	add_child.call_deferred(room)
	room.checksum_matched.connect(_on_room_name_checksum_matched)
	
	var tween = get_tree().create_tween()
	tween.tween_property(room, "position", Vector2(20,-130), (room.target_time*2.5))
	var free_unless_real = func():
		if !room.is_real:
			room.queue_free()
	tween.tween_callback(free_unless_real)

var id_sum = 0
func _on_room_name_checksum_matched(room_id):
	id_sum += room_id
	$Part1Label.text = "Part 1: %d" % id_sum
	speed_factor += 0.2

func part2():
	speed_factor = 4.0
	
	var rooms = get_tree().get_nodes_in_group("rooms")
	rooms.reverse()
	
	for room in rooms:
		room.setup_for_pt2()
		room.room_found.connect(_on_room_found)
		
		var tween = get_tree().create_tween()
		tween.tween_property(room, "position", Vector2(20, 800), (room.target_time*2.1))
		tween.tween_callback(room.queue_free)
		room.tween = tween
		
		await get_tree().create_timer(1.0 / (rooms_per_second * speed_factor)).timeout

func _on_room_found(room):
	if room.final_text() == "northpole-object-storage":
		$Part2Label.text += str(room.room_id())
		room.tween.pause()
		
		room.remove_from_group("rooms")
		get_tree().call_group("rooms", "hide")
