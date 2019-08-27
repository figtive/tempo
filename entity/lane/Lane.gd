extends Path2D

export(int) var lane_number

onready var note_scene = preload("res://entity/note/Note.tscn")
var queue = [[], [], [], []]

func _ready():
	$Hitter.unit_offset = GameManager.HITTER_POS

func spawn(action):
	if action != GameManager.Action.NONE:
		var note = note_scene.instance()
		queue[lane_number].push_back(note)
		note.set_type(action)
		add_child(note)

func pass_note(note, is_hit):
	if queue[lane_number].front() == note:
		queue[lane_number].pop_front()
	if is_hit:
		GameManager.SCORE += 1
	else:		
		pass
#		GameManager.SCORE -= 5

func hit(action):
	var result
	if queue[lane_number].size() > 0:
		var target: Note = queue[lane_number].front()
		if target != null:
			if target.hittable:
				result = target.hit(action)
			else:
				result = "MISSED"
		else:
			result = "NO NOTES"
	else:
		result = "NO NOTES"
	print("%s hits with %s -> %s" % [name, action, result])
	