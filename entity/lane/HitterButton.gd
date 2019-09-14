extends TouchScreenButton

var TOUCH_RADIUS
var touched_index
var trigger_level = 0

func _ready():
	TOUCH_RADIUS = (shape as CircleShape2D).radius
	
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if (global_position - position).distance_to(event.position) < TOUCH_RADIUS * 1.2:
				touched_index = event.index
				trigger_level = 1
				get_parent().get_parent().hit(GameManager.Action.TAP)
				$AnimationPlayer.play("Pressed")
		else:
			if touched_index != null:
				touched_index = null
				trigger_level = 0
				$AnimationPlayer.play_backwards("Pressed")
	if event is InputEventScreenDrag and event.index == touched_index and trigger_level == 1:
		trigger_level = 2
		var angle = event.relative.angle_to(Vector2(1,1))
		var action
		if angle >= 0 and angle < PI/2:
			action = GameManager.Action.SWIPE_RIGHT	# 4
		elif angle >= PI/2 and angle <= PI:
			action = GameManager.Action.SWIPE_UP	# 2
		elif angle < 0 and angle >= -PI/2:
			action = GameManager.Action.SWIPE_DOWN	# 1
		else:
			action = GameManager.Action.SWIPE_LEFT	# 3
		get_parent().get_parent().hit(action)

func _process(delta):
	pass