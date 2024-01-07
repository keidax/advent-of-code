extends Label

var progress = 0.0
var character = null

const SPINNER = ["—","\\","|","/"]

func _process(delta):
	if character:
		text = character
	else:
		progress += delta
		var sub_progress = int(fmod(progress, 1.0) * SPINNER.size())
		text = SPINNER[sub_progress]
