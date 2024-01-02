extends CanvasLayer


func _on_input_available(data):
	var lines = data.split("\n")
	
	await part1(lines)
	await part2(lines)
	
func part1(lines):
	$ButtonsPt1.begin()
	
	for line in lines:
		await $ButtonsPt1.handle_instruction_line(line)
	
	$ButtonsPt1.hide()

func part2(lines):
	$ButtonsPt2.begin()
	
	for line in lines:
		await $ButtonsPt2.handle_instruction_line(line)

func _on_buttons_pt_1_pressed(char):
	$Part1Label.text += char

func _on_buttons_pt_2_pressed(char):
	$Part2Label.text += char
