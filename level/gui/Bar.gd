extends TextureRect

var initial_size
var percentage = 0

func _ready():
	initial_size = $Cover.rect_size

func set_percentage(p):
	percentage = p
	var before = $Cover.rect_size
	var after = Vector2($Cover.rect_size.x, initial_size.y * (1 - p))
	$Tween.stop_all()
	$Tween.interpolate_property($Cover, "rect_size", before, after, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()