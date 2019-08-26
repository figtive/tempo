extends PathFollow2D

var START_POS = 0
var END_POS = 1.5
var TIME_OFFSET = 5

func _ready():
	$Tween.interpolate_property(self, "unit_offset",
		START_POS, END_POS, TIME_OFFSET,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()

func _process(delta):
	if unit_offset > 1.1:
		queue_free()
