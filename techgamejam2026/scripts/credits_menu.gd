extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	modulate = Color(1, 1, 1, 1)

func _on_close_pressed() -> void:
	hide()
