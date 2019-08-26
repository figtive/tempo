extends TouchScreenButton

var TOUCH_RADIUS
var touched_index

func _ready():
	TOUCH_RADIUS = (shape as CircleShape2D).radius
	pass # Replace with function body.

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if global_position.distance_to(event.position) < TOUCH_RADIUS * 2:
				touched_index = event.index
				print("%s touch by %s" % [get_parent().get_parent().name, touched_index])
		else:
			if touched_index != null:
				touched_index = null
				print("%s released" % get_parent().get_parent().name)
	if event is InputEventScreenDrag and event.index == touched_index:
		print("%s drag by %s" % [get_parent().get_parent().name, touched_index])

func _process(delta):
	pass