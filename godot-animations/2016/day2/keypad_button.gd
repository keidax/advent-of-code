extends Button

var glow = 0

func _ready():
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	
func _on_focus_changed(control):
	glow -= 1
	glow = clamp(glow, 0, 100)

func _on_focus_entered():
	glow += 6

func _process(delta):
	var stylebox = get_theme_stylebox("normal") as StyleBoxFlat
	stylebox.shadow_size = glow
