extends CanvasLayer
class_name GUIController

func _ready():
	change_display("game")

func change_display(display):
	match display:
		"game":
			$Game.show()
			$Pause.hide()
			$End.hide()
		"pause":
			$Game.hide()
			$Pause.show()
			$End.hide()
		"end":
			$Game.hide()
			$Pause.hide()
			$End.show()
		_:
			print("[GUIController] Display %s not found!" % display)

func update(target, value):
	match target:
		"score":
			$Game/Score.text = str(value)
		"multiplier":
			$Game/Multiplier.text = "x%s" % value
		"streak":
			$Game/Streak.text = str(value)
		"multiplier_bar":
			$Game/MultiplierBar.set_percentage(value)
		"progress_bar":
			$Game/ProgressBar.set_percentage(value)
		"title":
			$Game/Title.text = str(value)
		"origin":
			$Game/Origin.text = str(value)
		_:
			print("[GUIController] Unknown target %s" % target)
