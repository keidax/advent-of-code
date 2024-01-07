extends BoxContainer

@export var is_pt1: bool = true

var characters = []

signal entered(password)

func _ready():
	if !is_pt1:
		characters = {}

func add_character_for_hash(hash):
	if is_pt1:
		_add_pt1(hash)
	else:
		_add_pt2(hash)

func _add_pt1(hash):
	var i = characters.size()
	if i > 7:
		return
	
	var c = hash[5]
	characters.append(c)
	get_node("PasswordCharacter%d" % i).character = c
	
	if i == 7:
		var password = "".join(characters)
		entered.emit(password)

func _add_pt2(hash):
	var i = hash[5].hex_to_int()
	if i > 7 or i in characters:
		return
	
	var c = hash[6]
	characters[i] = c
	get_node("PasswordCharacter%d" % i).character = c

	if characters.size() == 8:
		var password = ""
		for char_i in range(0, 8):
			password += characters[char_i]
		entered.emit(password)
