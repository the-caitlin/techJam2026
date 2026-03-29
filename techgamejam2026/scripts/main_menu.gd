extends Control

@onready var credits_menu: Control = $CreditsMenu

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	credits_menu.hide()

func _on_play_pressed() -> void:
	Transition.fade_to_day(1, "res://scenes/days/day1.tscn")


func _on_credits_pressed() -> void:
	credits_menu.show()

func _on_quit_pressed() -> void:
	get_tree().quit()
