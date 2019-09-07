extends Node

enum Action {TAP = 5, SWIPE_UP = 1, SWIPE_DOWN = 2, SWIPE_LEFT = 3, SWIPE_RIGHT = 4, NONE = 0}
enum Pass {MATCH = 1, MISSED = 0}
enum Section {INTRO, BODY, OUTRO, STOP = 0}

const HITTER_POS = 0.74					# unit position of hitter on the lane
const HITTER_TOLERANCE = [0.64, 0.8]	# tolerance window for hitters
const PRE_BEAT = 3						# number of beats before note reaches hitter from spawn
var TIME_OFFSET = 0						# travel time from spawn to hitter
var NOTE_SPEED							# speed of note from unit 0 to 1

var BASE_SCORE = 100
var BASE_MULTIPLIER = 0.25
var BASE_MULT_PERCENT = 0.2

var MULTIPLIER = 1.0
var MULT_PERCENT = 0
var SCORE = 0
var STREAK = 0

var current_level: LevelController

func _ready():
	pass
	
func hit(hits):
	if hits:
		SCORE += (BASE_SCORE * MULTIPLIER) as int
		MULT_PERCENT += BASE_MULT_PERCENT
		STREAK += 1
		if MULT_PERCENT >= 1.0:
			MULT_PERCENT = 0
			MULTIPLIER += BASE_MULTIPLIER
			current_level.gui.update("multiplier", MULTIPLIER)
		current_level.gui.update("score", SCORE)
	else:
		SCORE += 0
		MULT_PERCENT = 0
		STREAK = 0
		MULTIPLIER = 1.0
		current_level.gui.update("multiplier", MULTIPLIER)
	current_level.gui.update("streak", STREAK)
	current_level.gui.update("multiplier_bar", MULT_PERCENT)
	
func calc_offset(bpm, manual_offset):
	TIME_OFFSET = (PRE_BEAT * 60 / bpm) + manual_offset
	NOTE_SPEED = TIME_OFFSET / HITTER_POS
	print("[GameManager] Offset: %ss" % TIME_OFFSET)
