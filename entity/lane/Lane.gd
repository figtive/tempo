extends Path2D

onready var note_scene = preload("res://entity/note/Note.tscn")

func _ready():
	pass

func spawn(action):
	if action != GameManager.Action.NONE:
		add_child(note_scene.instance())
