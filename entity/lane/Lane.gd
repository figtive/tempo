extends Path2D

onready var note_scene = preload("res://entity/note/Note.tscn")

func _ready():
	pass

func _process(delta):
	if rand_range(0, 5) < GameManager.DEBUG_RAND_SPAWN:
		var note = note_scene.instance()
		add_child(note)
		
	pass
