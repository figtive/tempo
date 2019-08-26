extends Node

export(String, FILE, "*.tempo") var tempo_data
var title: String
var origin: String
var bpm: float
var signature: int
var notes: Dictionary
var note_count = 0

var counter = 0

func _ready():
	var DEBUG_STARTTIME = OS.get_ticks_msec()
	var file = File.new()
	file.open(tempo_data, File.READ)
	parse(file.get_as_text())
	file.close()
	print("[LevelController] %s loaded successfully in %sms!" % [tempo_data, OS.get_ticks_msec() - DEBUG_STARTTIME])
	print("[LevelController] %s from %s @ %sbpm in %s sig" % [title, origin, bpm, signature])
	print("[LevelController] Notes: %s" % notes)
	
	if not $Metronome.is_connected("timeout", self, "beat"):
		$Metronome.connect("timeout", self, "beat")
	$Metronome.wait_time = 60.0 / bpm
	$Metronome.start()
	
	$DEBUG_hitline/Tween.interpolate_property($DEBUG_hitline, "color", Color(1,1,1,1), Color(1,1,1,0.25), 60.0/bpm, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$DEBUG_hitline/Tween.start()

func beat():
	var interval = notes.get(counter)
	if interval != null:
		$Lane1.spawn(interval[0])
		$Lane2.spawn(interval[1])
		$Lane3.spawn(interval[2])
		$Lane4.spawn(interval[3])
		print("Beat %s :: %s" % [counter, interval])
	else:
		print("Beat %s" % counter)
	counter += 1
	if counter > note_count:
		print("LevelManager] Level done!")
		$Metronome.stop()

func parse(data: String):
	var lines = data.split("\n", false)
	title = lines[0]
	origin = lines[1]
	bpm = lines[2] as float
	signature = lines[3].split(" ")[0] as int
	for i in range(4, lines.size()):
		note_count += 1
		var tokens = lines[i].split(" ", false)
		var beat = [GameManager.Action.NONE, GameManager.Action.NONE, GameManager.Action.NONE, GameManager.Action.NONE]
		for i in range(0, 5):
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
				notes[tokens[i] as int] = beat
