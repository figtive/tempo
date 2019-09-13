extends Node

signal beat(interval)
signal move(frame)

export(String, FILE, "*.tempo") var tempo_data
export(AudioStream) var music
export(bool) var auto_offset
export(float) var offset
export(int) var end_beat_count

export(bool) var DEBUG_TEMPO_V2

var time_begin
var time_delay

var title: String
var origin: String
var bpm: float
var signature: int
var notes: Dictionary
var current_bound = [0, 1]
var section_bound = []
var note_count = 0
var section = GameManager.Section.STOP

var beat_counter = 0
var frame_counter = 0

onready var gui: GUIController = $GUI

func _ready():
	get_tree().set_pause(false)
	GameManager.current_level = self
	var DEBUG_STARTTIME = OS.get_ticks_msec()
	var file = File.new()
	file.open(tempo_data, File.READ)
	parse(file.get_as_text())
	file.close()
	print("[LevelController] %s loaded successfully in %sms!" % [tempo_data, OS.get_ticks_msec() - DEBUG_STARTTIME])
	print("[LevelController] %s from %s @ %sbpm in %s sig" % [title, origin, bpm, signature])
	
	gui.update("title", title)
	gui.update("origin", origin)
	$Music.stream = music
	
	if not $Metronome.is_connected("timeout", self, "beat"):
		$Metronome.connect("timeout", self, "beat")
	$Metronome.wait_time = 60.0 / (bpm * signature)
	$GUI/DEBUG/Label2.text = "%s bpm @ %s/4" % [bpm, signature]
	
	if auto_offset:
		GameManager.calc_offset(bpm, offset)
	else:
		GameManager.TIME_OFFSET = offset
	$GUI/DEBUG/Label3.text = "%s s" % GameManager.TIME_OFFSET
	
	if not $OffsetTimer.is_connected("timeout", self, "start_music"):
		$OffsetTimer.connect("timeout", self, "start_music")
	$OffsetTimer.wait_time = GameManager.TIME_OFFSET
	$OffsetTimer.one_shot = true
	
	start_beat()

func pause(pause=true):
	if pause:
		get_tree().set_pause(true)
		gui.change_display("pause")
	else:
		gui.change_display("game")
		get_tree().set_pause(false)

func restart():
	get_tree().set_pause(false)
	GameManager.start_level(GameManager.current_level_idx)

func beat():
#	$Metronome/Beep.play()
	$GUI/DEBUG/Label4.text = str(beat_counter)
	gui.update("progress_bar", beat_counter / float(end_beat_count))
	move_dancer()
	var interval = notes.get(beat_counter + GameManager.PRE_BEAT * signature)
	if interval != null:
		spawn_notes(interval)
	beat_counter += 1
	if beat_counter > end_beat_count:
		print("[LevelManager] Level done! %s" % end_beat_count)
		$Metronome.stop()
		$Music.stop()
		gui.change_display("end")

func spawn_notes(interval):
	emit_signal("beat", interval)

func move_dancer():
	if beat_counter % signature == 0:
		if DEBUG_TEMPO_V2:
			var frame = notes.get(beat_counter, [null, null, null, null, null])[4]
			if frame == null:
				print("STEP %s" % [frame_counter])
				emit_signal("move", frame_counter)
				frame_counter = ((frame_counter - current_bound[0] + 1) % (current_bound[1] - current_bound[0])) + current_bound[0]
			else:
				frame_counter = frame
				match section:
					GameManager.Section.STOP:
						section = GameManager.Section.INTRO
						current_bound[0] = section_bound[0]
						current_bound[1] = section_bound[1]
						print("STOP -> INTRO [%s, %s)" % current_bound)
					GameManager.Section.INTRO:
						section = GameManager.Section.BODY
						current_bound[0] = section_bound[1]
						current_bound[1] = section_bound[2]
						print("INTRO -> BODY [%s, %s)" % current_bound)
					GameManager.Section.BODY:
						section = GameManager.Section.OUTRO
						current_bound[0] = section_bound[2]
						current_bound[1] = section_bound[3]
						print("BODY -> OUTRO [%s, %s)" % current_bound)
					GameManager.Section.OUTRO:
						section = GameManager.Section.STOP
						current_bound[0] = section_bound[3] - 1
						current_bound[1] = section_bound[3]
						print("OUTRO -> STOP [%s, %s)" % current_bound)
				emit_signal("move", frame_counter)
		else:
			emit_signal("move")

func start_beat():
	print("[LevelController] Starting level ...")
	$OffsetTimer.start()

func start_music():
	print("[LevelController] Starting music ...")
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
		var beat = [GameManager.Action.NONE, GameManager.Action.NONE, GameManager.Action.NONE, GameManager.Action.NONE, null]
		if tokens.size() > 5:
			beat[4] = tokens[5] as int
#			if section_bound.size() <= 1:
			section_bound.append(beat[4])
#			else:
#				section_bound.append(beat[4] + 1)
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

func exit():
	get_tree().set_pause(false)
	GameManager.return_menu()