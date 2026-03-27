extends Control

@onready var volume_slider: HSlider = %VolumeSlider
@onready var fullscreen_check: CheckButton = %FullscreenCheck

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	# Init values from current state
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.01
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_fullscreen_check_toggled(toggled: bool) -> void:
	if toggled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_close_pressed() -> void:
	hide()
