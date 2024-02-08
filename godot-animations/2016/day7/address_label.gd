extends Control

const Address = preload("res://2016/day7/address.gd")

var address: Address
var text: String:
	set(value):
		assert(value.length() > 0)
		text = value
		address = Address.new(text)
		char_advances = get_advances_for_string(text)
		size = Vector2(char_advances[-1].x+20, 50)

var ts = TextServerManager.get_primary_interface()
var font = get_theme_default_font()
var font_rid = font.get_rids()[0]
var font_size = 20

var char_advances: Array
var char_colors: Array = []

func setup_pt1():
	char_colors.clear()
	compute_colors_pt1()
	assert(char_colors.size() == text.length())
	queue_redraw()
	
func setup_pt2():
	char_colors.clear()
	compute_colors_pt2()
	assert(char_colors.size() == text.length())
	queue_redraw()
		
func compute_colors_pt1():
	var i = 0
	while i < text.length():
		if i in address.brackets:
			char_colors.append(Color.WHITE)
			i += 1
			continue
			
		var region_matched = false
		for reg in address.abba_regions:
			if reg[0] == i:
				var color: Color
				if reg[1]:
					color = Color.GREEN
				else:
					color = Color.RED
				for j in 4:
					char_colors.append(color)
				i += 4
				region_matched = true
				break
				
		if region_matched:
			continue
			
		char_colors.append(Color.DIM_GRAY)
		i += 1

func compute_colors_pt2():
	var i = 0
	while i < text.length():
		if i in address.brackets:
			char_colors.append(Color.WHITE)
			i += 1
			continue
			
		if i in address.aba_regions:
			for j in 3:
				char_colors.append(Color.LIGHT_SEA_GREEN)
			i += 3
			continue
			
		char_colors.append(Color.DIM_GRAY)
		i += 1

func _draw():
	for i in range(text.length()):
		draw_char(font, char_advances[i], text[i], font_size, char_colors[i])

func get_advances_for_string(string):
	var ascent = ts.font_get_ascent(font_rid, font_size)
	var pos = Vector2(0, ascent)
	var advances = [Vector2(pos)]
	
	for c in string:
		var glyph_i = ts.font_get_glyph_index(font_rid, font_size, c.unicode_at(0), 0)
		var advance = ts.font_get_glyph_advance(font_rid, font_size, glyph_i)
		pos.x += advance.x
		advances.append(Vector2(pos))
	
	return advances
