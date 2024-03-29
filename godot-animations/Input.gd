extends Node

@export var year : int = 2016
@export var day : int

@onready var file_path = "res://input/%d/%02d.txt" % [year, day]

signal available(data)

# Called when the node enters the scene tree for the first time.
func _ready():
	if !FileAccess.file_exists(file_path):
		download_data()
		await $HTTPRequest.request_completed
	
	var data = FileAccess.get_file_as_string(file_path)
	var error = FileAccess.get_open_error()
	assert(error == OK, error_string(error))
	
	available.emit(data.strip_edges())

func download_data():
	var session_token = OS.get_environment("AOC_SESSION")
	assert(!session_token.is_empty(), "missing AOC_SESSION env var")
	
	var url = "https://adventofcode.com/%d/day/%d/input" % [year, day]
	var headers = ["Cookie: session=%s" % session_token]
	
	var error = $HTTPRequest.request(url, headers)
	assert(error == OK, error_string(error))

func _on_request_completed(result, response_code, headers, body):
	assert(result == HTTPRequest.RESULT_SUCCESS)
	
	if response_code == 200:
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_buffer(body)
	else:
		assert(response_code == 200, "Puzzle download failed: " + body.get_string_from_utf8())
