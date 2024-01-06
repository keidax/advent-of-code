extends Control

var current_time = 0.0
var target_time = 2
var progress = 0.0

var ts = TextServerManager.get_primary_interface()
var font = get_theme_default_font()
var font_rid = font.get_rids()[0]
var font_size = 20

@export var text: String
var target_text = ""
var end_of_name = -1
var start_of_checksum = -1
var is_real:bool

var start_of_checksum_pos:Vector2
var font_leading:float = -1

var target_char_positions = []
var initial_text_positions = []

signal checksum_matched(room_id)
signal room_found(room)

var is_pt2: bool = false
var tween: Tween = null

# Do initial calculations for the room data
func _ready():
	end_of_name = text.rfind("-")
	var room_name = text.substr(0, end_of_name)
	var chars = room_name.replace("-", "").split("")
	
	var tally = {}
	for c in chars:
		if c in tally:
			tally[c] += 1
		else:
			tally[c] = 1
	
	var max_count = 0
	var inverse_tally = {}
	for c in tally:
		var count = tally[c]
		max_count = max(count, max_count)
		if count in inverse_tally:
			inverse_tally[count].append(c)
		else:
			inverse_tally[count] = [c]
	
	for count in range(max_count, 0, -1):
		if count in inverse_tally:
			var count_chars = inverse_tally[count]
			count_chars.sort()
			target_text += "".join(count_chars)
	
	target_char_positions = get_advances_for_string(target_text)
	initial_text_positions = get_advances_for_string(text)
	var bracket_i = text.find("[")
	start_of_checksum = bracket_i + 1
	start_of_checksum_pos = initial_text_positions[start_of_checksum]
	
	var checksum = text.substr(start_of_checksum, 5)
	is_real = checksum == target_text.substr(0, 5)
	
	var ascent = ts.font_get_ascent(font_rid, font_size)
	var descent = ts.font_get_descent(font_rid, font_size)
	font_leading = ascent+descent
	
	# The size must be set for on-screen checking. Otherwise this scene will
	# disappear as soon as the origin is off-screen.
	self.size = Vector2(initial_text_positions[-1].x, font_leading*4)

func get_advances_for_string(string):
	var ts = TextServerManager.get_primary_interface()
	var ascent = ts.font_get_ascent(font_rid, font_size)
	var pos = Vector2(0, ascent)
	var advances = [Vector2(pos)]
	
	for c in string:
		var glyph_i = ts.font_get_glyph_index(font_rid, font_size, c.unicode_at(0), 0)
		var advance = ts.font_get_glyph_advance(font_rid, font_size, glyph_i)
		pos.x += advance.x
		advances.append(Vector2(pos))
	
	return advances

func setup_for_pt2():
	is_pt2 = true
	current_time = 0.0
	target_time = 2
	progress = 0.0

func _draw():
	if is_pt2:
		_draw_pt2()
	else:
		_draw_pt1()
	
# Animate the validation of the room name against the checksum
func _draw_pt1():
	var initial_offset = Vector2(0, 0)
	var final_offset = Vector2(start_of_checksum_pos.x, font_leading)
	
	var stacked_chars = {}
	
	for i in range(text.length()):
		var result_color = Color.WHITE
		
		var initial_pos = initial_offset + initial_text_positions[i]
		var pos = null
		var char = text[i]
		if i > end_of_name || !(char in target_text):
			pos = initial_pos
			
			if progress >= 1.0 && i in range(start_of_checksum, start_of_checksum+5):
				if is_real:
					result_color = Color.GREEN
				else:
					result_color = Color.RED
			draw_char(font, pos, text[i], font_size, result_color)
		else:
			var char_i = target_text.find(char)
			var stacks = 0
			
			if char in stacked_chars:
				stacks = stacked_chars[char]
				stacked_chars[char] += 1
			else:
				stacked_chars[char] = 1
			
			var target_alpha = 0.8
			if stacks > 2:
				target_alpha = 0.0
			else:
				target_alpha -= (0.33 * stacks)
			
			result_color.a = lerp(1.0, target_alpha, progress)
			
			var final_pos = final_offset + target_char_positions[char_i] + Vector2(0, stacks * font_leading)
			pos = initial_pos.lerp(final_pos, progress)
			draw_char(font, pos, text[i], font_size, result_color)

# Animate the decryption of the room name
func _draw_pt2():
	var main_text = text.substr(0, end_of_name)
	var pos = initial_text_positions[0]
	
	var initial_rot = 0
	var final_rot = room_id()%26
	
	var interp_rot = int(lerp(initial_rot, final_rot, progress))
	
	var deciphered = rot_cipher(main_text, interp_rot)
	draw_string(font, pos, deciphered, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	
	var pre_checksum = text.substr(end_of_name, start_of_checksum-end_of_name)
	pos = initial_text_positions[end_of_name]
	draw_string(font, pos, pre_checksum, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	
	var checksum = text.substr(start_of_checksum, 5)
	pos = initial_text_positions[start_of_checksum]
	draw_string(font, pos, checksum, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.GREEN)
	
	pos = initial_text_positions[-2]
	draw_string(font, pos, "]", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

var a_offset = "a".unicode_at(0)

func rot_cipher(text, num):
	var result = []
	
	for c in text:
		var codepoint = c.unicode_at(0)
		if codepoint in range(a_offset, a_offset+26):
			var alpha = codepoint - a_offset
			alpha += num
			alpha %= 26
			result.append(String.chr(alpha + a_offset))
		else:
			result.append(c)

	return "".join(result)

var _room_id = null
func room_id():
	if _room_id:
		return _room_id
	
	var start_of_id = end_of_name + 1
	var end_of_id = text.find("[")
	var id_str = text.substr(start_of_id, end_of_id - start_of_id)
	_room_id = int(id_str)
	return _room_id
	
func final_text():
	return rot_cipher(text.substr(0, end_of_name), room_id())

func _process(delta):
	current_time += delta
	if current_time >= target_time:
		if progress < 1.0:
			progress = 1.0
			queue_redraw()
			
			if is_real:
				if is_pt2:
					room_found.emit(self)
				else:
					checksum_matched.emit(room_id())
	else:
		progress = current_time/target_time
		queue_redraw()
