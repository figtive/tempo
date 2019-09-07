extends TextureRect

var initial_size
var percentage = 0

func _ready():
	initial_size = $Cover.rect_size.y

func set_percentage(p):
	percentage = p
	$Cover.rect_size.y = initial_size * (1 - p)
	print(rect_size.y)