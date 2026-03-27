extends CanvasLayer

var _overlay: ColorRect

func _ready() -> void:
	layer = 10  # always on top
	_overlay = ColorRect.new()
	_overlay.color = Color.BLACK
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.modulate.a = 0.0
	add_child(_overlay)

func fade_to_scene(path: String, duration: float = 0.8) -> void:
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(_overlay, "modulate:a", 1.0, duration)
	tween.tween_callback(func(): get_tree().change_scene_to_file(path))
	tween.tween_property(_overlay, "modulate:a", 0.0, duration)
	tween.tween_callback(func(): _overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE)
