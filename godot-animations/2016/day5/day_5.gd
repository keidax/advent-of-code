extends CanvasLayer

signal match_found(hash)

var md5_thread : Thread
var thread_keep_running : bool = true

func _on_input_available(data):
	md5_thread = Thread.new()
	md5_thread.start(find_zeros.bind(data))

func find_zeros(input):
	var i = 0
	var hash = ""
	input += "%d"
	while thread_keep_running:
		hash = (input % i).md5_text()
		if hash.begins_with("00000"):
			call_deferred("emit_signal", "match_found", hash)
		i += 1

func _on_match_found(hash):
	$PasswordPt1.add_character_for_hash(hash)
	$PasswordPt2.add_character_for_hash(hash)

func _on_password_pt_1_entered(password):
	$Part1Label.text += password

func _on_password_pt_2_entered(password):
	$Part2Label.text += password
	
	thread_keep_running = false
	md5_thread.wait_to_finish()
