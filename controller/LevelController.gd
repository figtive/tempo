extends Node

export(String, FILE, "*.tempo") var tempo_data

var title: String
var origin: String
var bpm: int
var signature: int
var notes: Dictionary

func _ready():
	var DEBUG_STARTTIME = OS.get_ticks_msec()
	var file = File.new()
	file.open(tempo_data, File.READ)
	parse(file.get_as_text())
	print("[LevelController] %s loaded successfully in %sms!" % [tempo_data, OS.get_ticks_msec() - DEBUG_STARTTIME])
	print("[LevelController] %s from %s @ %sbpm in %s sig" % [title, origin, bpm, signature])
	print("[LevelController] Notes: %s" % notes)

func parse(data: String):
	var lines = data.split("\n", false)
	title = lines[0]
	origin = lines[1]
	bpm = lines[2] as int
	signature = lines[3].split(" ")[0] as int
	for i in range(4, lines.size()):
		var tokens = lines[i].split(" ", false)
		print(tokens)
		var beat = [GameManager.Action.NONE, GameManager.Action.NONE, GameManager.Action.NONE, GameManager.Action.NONE]
		for i in range(0, 5):
			print(tokens[i])
			if i != 0:	
				match tokens[i].to_upper():
					"T":
						beat[i-1] = GameManager.Action.TAP
					"U":
						beat[i-1] = GameManager.Action.SWIPE_UP
					"D":
						beat[i-1] = GameManager.Action.SWIPE_DOWN
					"L":
						beat[i-1] = GameManager.Action.SWIPE_LEFT
					"R":
						beat[i-1] = GameManager.Action.SWIPE_RIGHT
			else:
				print(beat)
				notes[tokens[i]] = beat
