extends Control

signal pressed(char)

var steps_per_second = 10000

func begin():
	show()
	$Button5.grab_focus()

func handle_instruction_line(data):
	for i in range(0, data.length()):
		var action = null
		match data[i]:
			"L": action = "ui_left"
			"R": action = "ui_right"
			"U": action = "ui_up"
			"D": action = "ui_down"
		
		_do_ui_action(action)
		await get_tree().create_timer(1.0 / steps_per_second).timeout
		
	var char = get_viewport().gui_get_focus_owner().text
	pressed.emit(char)
	print(char)
		
func _do_ui_action(action):
	var event = InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
