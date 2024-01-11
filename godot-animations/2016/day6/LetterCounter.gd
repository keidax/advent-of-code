extends Control

var ts = TextServerManager.get_primary_interface()
var font = get_theme_default_font()
var font_rid = font.get_rids()[0]
var font_size = 18

var ascent = ts.font_get_ascent(font_rid, font_size)
var descent = ts.font_get_descent(font_rid, font_size)

var characters = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var glyph = "a".unicode_at(0)
	var glyph_i = ts.font_get_glyph_index(font_rid, font_size, glyph, 0)
	var advance = ts.font_get_glyph_advance(font_rid, font_size, glyph_i)
	
	print(advance)
	size = Vector2(advance.x, (ascent + descent) * 26)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func add_character(c):
	if c in characters:
		characters[c] += 1
	else:
		characters[c] = 1
		
	queue_redraw()
	
func character_order():
	var max_count = 0
	var inverse_characters = {}
	
	for c in characters:
		var count = characters[c]
		max_count = max(count, max_count)
		if count in inverse_characters:
			inverse_characters[count].append(c)
		else:
			inverse_characters[count] = [c]
	
	var result = []
	for count in range(max_count, 0, -1):
		if count in inverse_characters:
			var count_chars = inverse_characters[count]
			#count_chars.sort()
			result.append_array(count_chars)
	
	return result

func _draw():
	var pos = Vector2(0, ascent)
	
	var chars = character_order()
	var top_color = Color.GREEN
	var mid_color = Color.GRAY
	var bottom_color = Color.RED
	
	for i in range(chars.size()):
		var percent = i * 2.0 / (chars.size() - 1)
		
		var draw_color = null
		if percent < 1.0:
			draw_color = top_color.lerp(mid_color, percent)
		else:
			draw_color = mid_color.lerp(bottom_color, percent - 1.0)
		
		draw_char(font, pos, chars[i], font_size, draw_color)
		pos.y += ascent + descent
