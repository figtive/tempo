extends Node

signal beat

export(String, FILE, "*.tempo") var tempo_data
export(String, FILE, "*.wav") var music
export(bool) var auto_offset
export(float) var offset

var time_begin
var time_delay

var title: String
var origin: String
var bpm: float
var signature: int
var notes: Dictionary
var note_count = 0

var counter = 0
var ready = false

func _ready():
	$HTTPRequest.request("https://gitlab.com/fight-interactive/tempo-public/snippets/1889052/raw")
	yield($HTTPRequest, "request_completed")
	print("Downloaded!")
	
	var DEBUG_STARTTIME = OS.get_ticks_msec()
	var file = File.new()
	file.open(tempo_data, File.READ)
	parse(file.get_as_text())
	file.close()
	print("[LevelController] %s loaded successfully in %sms!" % [tempo_data, OS.get_ticks_msec() - DEBUG_STARTTIME])
	print("[LevelController] %s from %s @ %sbpm in %s sig" % [title, origin, bpm, signature])
	print("[LevelController] Notes: %s" % notes)
	$CanvasLayer/Label2.text = "%s bpm" % bpm
	
	if not $Metronome.is_connected("timeout", self, "beat"):
		$Metronome.connect("timeout", self, "beat")
	$Metronome.wait_time = 60.0 / (bpm * 1)
#	$LaneContainer/DEBUG_hitline/Tween.interpolate_property($LaneContainer/DEBUG_hitline, "color", Color(1,1,1,1), Color(1,1,1,0.25), 60.0/bpm, Tween.TRANS_QUAD, Tween.EASE_OUT)
#	$LaneContainer/DEBUG_hitline/Tween.start()
	
	if auto_offset:
		GameManager.calc_offset()
	else:
		GameManager.TIME_OFFSET = offset
	$CanvasLayer/Label3.text = "%s s" % GameManager.TIME_OFFSET
	
	if not $OffsetTimer.is_connected("timeout", self, "start_music"):
		$OffsetTimer.connect("timeout", self, "start_music")
	$OffsetTimer.wait_time = GameManager.TIME_OFFSET
	$OffsetTimer.one_shot = true
	
	start_beat()

func _process(delta):
	$CanvasLayer/Label.text = str(GameManager.SCORE)
	
func beat():
	$Metronome/Beep.play()
	var interval = notes.get(counter)
	if interval != null:
		emit_signal("beat", interval)
		$LaneContainer/Lane1.spawn(interval[0])
		$LaneContainer/Lane2.spawn(interval[1])
		$LaneContainer/Lane3.spawn(interval[2])
		$LaneContainer/Lane4.spawn(interval[3])
#		print("Beat %s :: %s" % [counter, interval])
	counter += 1
	if counter > note_count:
		print("LevelManager] Level done!")
		$Metronome.stop()
		$LaneContainer/DEBUG_hitline/Tween.stop_all()

func start_beat():
	$OffsetTimer.start()

func start_music():
	print("MUSIC STARTS")
	$Music.play()
	$Metronome.start()

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
