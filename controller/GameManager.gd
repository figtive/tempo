extends Node

enum Action {TAP = 5, SWIPE_UP = 1, SWIPE_DOWN = 2, SWIPE_LEFT = 3, SWIPE_RIGHT = 4, NONE = 0}

const HITTER_POS = 0.75
const NOTE_SPEED = 5
var TIME_OFFSET = 0

func _ready():
	calc_offset()
	
func calc_offset():
	TIME_OFFSET = sqrt(HITTER_POS / NOTE_SPEED) * NOTE_SPEED
