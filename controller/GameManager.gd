extends Node

enum Action {TAP = 5, SWIPE_UP = 1, SWIPE_DOWN = 2, SWIPE_LEFT = 3, SWIPE_RIGHT = 4, NONE = 0}
enum Pass {MATCH = 1, MISSED = 0}

const HITTER_POS = 0.74					# unit position of hitter on the lane
const HITTER_TOLERANCE = [0.64, 0.8]	# tolerance window for hitters
const PRE_BEAT = 4						# number of beat before note reaches hitter from spawn
var TIME_OFFSET = 0						# travel time from spawn to hitter
var NOTE_SPEED							# speed of note from unit 0 to 1

var SCORE = 0

func _ready():
	pass
	
func calc_offset(bpm, manual_offset):
	TIME_OFFSET = (PRE_BEAT * 60 / bpm) + manual_offset
	NOTE_SPEED = TIME_OFFSET / HITTER_POS
	print("[GameManager] Offset: %ss" % TIME_OFFSET)
