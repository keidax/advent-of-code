extends Control

var streets = 300

var street_color = Color(0.3, 0.3, 0.3, 0.4)
var axis_color = Color(0.5, 0.5, 0.5, 1)

func _draw():
	
	var street_points = []
	
	for x in range(-streets, streets+1, 10):
		street_points.append(Vector2(x, -streets))
		street_points.append(Vector2(x, +streets))
		street_points.append(Vector2(-streets, x))
		street_points.append(Vector2(+streets, x))

	draw_multiline(street_points, street_color, -1)

	draw_line(Vector2(0, -streets), Vector2(0, streets), axis_color, 1)
	draw_line(Vector2(-streets, 0), Vector2(streets, 0), axis_color, 1)
