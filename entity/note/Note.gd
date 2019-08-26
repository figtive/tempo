extends PathFollow2D

const START_POS = 0		# DO NOT CHANGE!
const END_POS = 2		# DO NOT CHANGE!

func _ready():
	$Timer.wait_time = GameManager.TIME_OFFSET
	$Tween.interpolate_property(self, "unit_offset",
		START_POS, END_POS, GameManager.NOTE_SPEED,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Timer.start()
	yield($Timer, "timeout")
	$Tween.start()

func _process(delta):
	if unit_offset >= 1:
		queue_free()
