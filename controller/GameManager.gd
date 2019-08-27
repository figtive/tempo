extends Node

enum Action {TAP = 5, SWIPE_UP = 1, SWIPE_DOWN = 2, SWIPE_LEFT = 3, SWIPE_RIGHT = 4, NONE = 0}
enum Pass {MATCH = 1, MISSED = 0}

const HITTER_POS = 0.75
const HITTER_TOLERANCE = [0.6, 0.8]
const NOTE_SPEED = 4
var TIME_OFFSET = 0

var SCORE = 0

func _ready():
	pass
	
func calc_offset():
#	TIME_OFFSET = sqrt(HITTER_POS * sqrt(2) / NOTE_SPEED) / (sqrt(2) / NOTE_SPEED)
#	TIME_OFFSET = (sqrt(1 - HITTER_POS) + 1) / NOTE_SPEED
	TIME_OFFSET = (1 - sqrt(HITTER_POS)) / NOTE_SPEED
