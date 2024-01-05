extends RigidBody2D

var green = Color(0.0, 0.33, 0.0)
var red = Color(0.33, 0.0, 0.0)

@export var lengths : Array:
	set(value):
		assert(value.size() == 3)
		
		value.sort()
		var a = value[0]
		var b = value[1]
		var c = value[2]
		
		var angle_a = acos((b**2 + c**2 - a**2) / (2.0 * b * c))
		
		var point1 = Vector2(0, 0)
		var point2 = Vector2(c, 0)
		var point3 = Vector2(cos(angle_a)*b, sin(angle_a)*b)
		
		var centroid = Vector2(
			(point1.x + point2.x + point3.x)/3.0,
			(point1.y + point2.y + point3.y)/3.0, 
		)
		
		$CollisionShape2D.polygon = [point1, point2, point3]
		$Polygon2D.polygon = [point1, point2, point3]
		
		# If we don't define the center of mass like this, it defaults to the origin. In this
		# case, that's one of the vertexes of the triangle, which gives weird physics results.
		center_of_mass = centroid

		# For visual variety, flip triangles so they don't all have the same
		# orientation (and switch colors)
		if randi() % 2 == 0:
			$Polygon2D.color = green
		else:
			$Polygon2D.color = red
			scale = Vector2(1, -1)
			
		# Put triangle onto a random layer, to reduce the overall number of collision pairs
		var layer = randi() % 12
		collision_layer = 1 << layer
		collision_mask = 1 << layer
