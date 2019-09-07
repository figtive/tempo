extends CanvasLayer
class_name GUIController

func _ready():
	pass

func update(target, value):
	match target:
		"score":
			$Score.text = str(value)
		"multiplier":
			$Multiplier.text = "x%s" % value
		"streak":
			$Streak.text = str(value)
		"multiplier_bar":
			$MultiplierBar.set_percentage(value)
		"progress_bar":
			$ProgressBar.set_percentage(value)
		"title":
			$Title.text = str(value)
		"origin":
			$Origin.text = str(value)
		_:
			print("[GUIController] Unknown target %s" % target)