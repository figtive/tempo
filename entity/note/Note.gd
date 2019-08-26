extends PathFollow2D

var START_POS = 0
var HIT_POS = 1

func _ready():
	$Timer.wait_time = GameManager.TIME_OFFSET
	$Tween.interpolate_property(self, "unit_offset",
		START_POS, HIT_POS, GameManager.NOTE_SPEED,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Timer.start()
	$Tween.start()
	var p = OS.get_ticks_msec()
	yield($Timer, "timeout")
	print("ok %s" % [OS.get_ticks_msec() - p])

func _process(delta):
	if unit_offset > 1.1:
		queue_free()
