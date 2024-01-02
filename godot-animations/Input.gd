extends Node

@export var year : int = 2016
@export var day : int

@onready var file_path = "res://input/%d/%02d.txt" % [year, day]

signal available(data)

# Called when the node enters the scene tree for the first time.
func _ready():
	if !FileAccess.file_exists(file_path):
		download_data()
	
	var data = FileAccess.get_file_as_string(file_path)
	var error = FileAccess.get_open_error()
	assert(error == OK, error_string(error))
	
	available.emit(data)

func download_data():
	pass
