extends CanvasLayer

var addresses_per_second = 15
var address_labels = []

func _on_input_available(data):
	var lines = data.split("\n")
	
	await part1(lines)
	await get_tree().create_timer(3).timeout
	part2()

func part1(lines):
	for address in lines:
		var address_label = preload("res://2016/day7/address_label.tscn").instantiate()
		address_label.add_to_group("addresses")
		address_label.text = address
		address_labels.append(address_label)
		
	var result = 0
	for address_label in address_labels:
		if address_label.address.supports_tls == false || address_label.address.supports_tls == true:
			address_label.setup_pt1()
			add_address_node(address_label)
			await get_tree().create_timer(1.0/addresses_per_second).timeout
			
			if address_label.address.supports_tls == true:
				result += 1
				$Part1Label.text = "Part 1: %d" % result
				
func part2():
	var result = 0
	for address_label in address_labels:
		if address_label.address.supports_ssl == true:
			address_label.setup_pt2()
			add_address_node(address_label, true)
			await get_tree().create_timer(1.0/addresses_per_second).timeout
			result += 1
			$Part2Label.text = "Part 2: %d" % result
			
func add_address_node(node, reverse = false):
	var node_width = node.char_advances[-1].x
	
	var y = randf_range(175, 700)
	
	var start = Vector2(-(node_width + 40), y)
	var finish = Vector2(800, y)
	
	var tween = get_tree().create_tween()
	
	if reverse:
		var t = finish
		finish = start
		start = t
		
	node.position = start
	tween.tween_property(node, "position", finish, 2.5)
	
	var remove_child_later = func():
		remove_child.call_deferred(node)
	tween.tween_callback(remove_child_later)
	
	add_child.call_deferred(node)
