extends CanvasLayer

var messages_per_second = 60

func _on_input_available(data):
	var lines = data.split("\n")
	await parse_messages(lines)
	display_results()
	
func parse_messages(lines):
	for line in lines:
		add_message(line)
		await get_tree().create_timer(1.0 / messages_per_second).timeout

func add_message(message):
	var chars = message.split("")
	
	for i in range(chars.size()):
		var node = get_node("BoxContainer/LetterCounter%d" % i)
		node.add_character(chars[i])
		
func display_results():
	for i in range($BoxContainer.get_child_count()):
		var node = get_node("BoxContainer/LetterCounter%d" % i)
		var node_result = node.character_order()
		$Part1Label.text += node_result[0]
		$Part2Label.text += node_result[-1]
