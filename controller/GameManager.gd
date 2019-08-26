extends Node

enum Action {TAP = 5, SWIPE_UP = 1, SWIPE_DOWN = 2, SWIPE_LEFT = 3, SWIPE_RIGHT = 4, NONE = 0}

const HITTER_POS = 0.75
const NOTE_SPEED = 6
var TIME_OFFSET = 0

func _ready():
	calc_offset()
	print("TIME_OFFSET %sms" % (TIME_OFFSET * 1000))
	
func calc_offset():
#	TIME_OFFSET = sqrt(HITTER_POS / NOTE_SPEED) * NOTE_SPEED
	TIME_OFFSET = sqrt(HITTER_POS * sqrt(2) / NOTE_SPEED) / (sqrt(2) / NOTE_SPEED)
