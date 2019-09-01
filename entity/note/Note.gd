extends PathFollow2D
class_name Note

export(Texture) var texture_up
export(Texture) var texture_down
export(Texture) var texture_left
export(Texture) var texture_right
export(Texture) var texture_tap

const START_POS = 0		# DO NOT CHANGE!
const END_POS = 1		# DO NOT CHANGE!
const GROW_SIZE = Vector2(1.05, 1.05)
var TYPE

var hittable = false

func _ready():
	$Tween.interpolate_property(self, "unit_offset",
		START_POS, END_POS, GameManager.NOTE_SPEED,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property($Sprite, "scale",
		$Sprite.scale, GROW_SIZE, GameManager.NOTE_SPEED,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
func set_type(type):
	self.TYPE = type
	match type:
		GameManager.Action.SWIPE_UP:
			$Sprite.texture = texture_up
		GameManager.Action.SWIPE_DOWN:
			$Sprite.texture = texture_down
		GameManager.Action.SWIPE_LEFT:
			$Sprite.texture = texture_left
		GameManager.Action.SWIPE_RIGHT:
			$Sprite.texture = texture_right
		GameManager.Action.TAP:
			$Sprite.texture = texture_tap
	
func hit(action):
	if TYPE != GameManager.Action.TAP and action == GameManager.Action.TAP:
		return "WAIT"
	else:
		hittable = false
		if TYPE == action:
			$Sprite.modulate = Color(0,1,0)
			get_parent().pass_note(self, true)
			return "HIT"
		else:
			$Sprite.modulate = Color(1,0,0)
			get_parent().pass_note(self, false)
			return "WRONG"

func _physics_process(delta):
	if unit_offset >= GameManager.HITTER_TOLERANCE[0] and unit_offset < GameManager.HITTER_TOLERANCE[1]:
		hittable = true
		$Sprite.modulate = Color(1,1,0)
	if unit_offset >= GameManager.HITTER_TOLERANCE[1] and hittable:
		hit(GameManager.Action.NONE)
	if unit_offset >= 1:
		queue_free()
