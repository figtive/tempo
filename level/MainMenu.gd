extends Node

const SCREEN_WIDTH = 720	# Use the value from project settings

var level_count = 3
var selected_level = 0

func _ready():
	$GUI/Levels/VBoxContainer/VBoxContainer/ScrollContainer.scroll_horizontal = selected_level * SCREEN_WIDTH
	change_menu("main")

func _process(delta):
	if Input.is_key_pressed(KEY_BACKSLASH):
		change_menu("main")

func change_menu(menu):
	match menu:
		"main":
			$GUI/Main.show()
			$GUI/Levels.hide()
			$GUI/Settings.hide()
		"levels":
			$GUI/Main.hide()
			$GUI/Levels.show()
			$GUI/Settings.hide()
		"settings":
			$GUI/Main.hide()
			$GUI/Levels.hide()
			$GUI/Settings.show()
		_:
			print("[MainMenu] Unknown menu  %s" % menu)

func play():
	print("PLAY")
	GameManager.start_level(selected_level)

func scroll(is_scrolling):
	if !is_scrolling:
		var position = $GUI/Levels/VBoxContainer/VBoxContainer/ScrollContainer.scroll_horizontal
		for level in range(level_count):
			if position < (level * SCREEN_WIDTH) + SCREEN_WIDTH / 2:
				selected_level = level
				snap_level(level, position)
				break

func snap_level(level, position=$GUI/Levels/VBoxContainer/VBoxContainer/ScrollContainer.scroll_horizontal):
	$Tween.stop($GUI/Levels/VBoxContainer/VBoxContainer/ScrollContainer, "scroll_horizontal")
	$Tween.interpolate_property($GUI/Levels/VBoxContainer/VBoxContainer/ScrollContainer,
		"scroll_horizontal", position, level * SCREEN_WIDTH, 0.35, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	$Tween.start()
