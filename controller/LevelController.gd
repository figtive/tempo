extends Node

signal beat(interval)

export(String, FILE, "*.tempo") var tempo_data
export(AudioStream) var music
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
	var DEBUG_STARTTIME = OS.get_ticks_msec()
	var file = File.new()
	file.open(tempo_data, File.READ)
	parse(file.get_as_text())
	file.close()
	print("[LevelController] %s loaded successfully in %sms!" % [tempo_data, OS.get_ticks_msec() - DEBUG_STARTTIME])
	print("[LevelController] %s from %s @ %sbpm in %s sig" % [title, origin, bpm, signature])
	
	$GUI/Title.text = title
	$GUI/Origin.text = origin
	$Music.stream = music
	
	if not $Metronome.is_connected("timeout", self, "beat"):
		$Metronome.connect("timeout", self, "beat")
	$Metronome.wait_time = 60.0 / (bpm * signature)
	$GUI/Label2.text = "%s bpm @ %s/4" % [bpm, signature]
	
	if auto_offset:
		GameManager.calc_offset(bpm, offset)
	else:
		GameManager.TIME_OFFSET = offset
	$GUI/Label3.text = "%s s" % GameManager.TIME_OFFSET
	
	if not $OffsetTimer.is_connected("timeout", self, "start_music"):
		$OffsetTimer.connect("timeout", self, "start_music")
	$OffsetTimer.wait_time = GameManager.TIME_OFFSET
	$OffsetTimer.one_shot = true
	
	counter = GameManager.PRE_BEAT * signature
	
	start_beat()

func _process(delta):
	$GUI/Label.text = str(GameManager.SCORE)
	
func beat():
	$Metronome/Beep.play()
	$GUI/Label4.text = str(counter - GameManager.PRE_BEAT * signature)	# compensate prebeat for debugging
	move_dancer()
	var interval = notes.get(counter)
	if interval != null:
		spawn_notes(interval)
	counter += 1
	if counter > note_count:
		print("[LevelManager] Level done!")
#		$Metronome.stop()
		
func spawn_notes(interval):
	emit_signal("beat", interval)

func move_dancer():
	if counter % signature % 2 == 0:
		$StageContainer/Dancer.next()
		$StageContainer/Dancer2.next()

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
