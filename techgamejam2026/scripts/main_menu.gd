extends Control

@onready var settings_menu: Control = $SettingsMenu
@onready var credits_menu: Control = $CreditsMenu

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	settings_menu.hide()
	credits_menu.hide()

func _on_play_pressed() -> void:
	Transition.fade_to_scene("res://scenes/days/day1.tscn")

func _on_settings_pressed() -> void:
	settings_menu.show()

func _on_credits_pressed() -> void:
	credits_menu.show()

func _on_quit_pressed() -> void:
	get_tree().quit()
