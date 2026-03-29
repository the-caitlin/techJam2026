extends CanvasLayer

const DayTransitionScene := preload("res://scenes/days/dayTransition.tscn")

var _overlay: ColorRect

func _ready() -> void:
	layer = 10
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

func fade_to_day(day_number: int, next_scene: String, duration: float = 0.8) -> void:
	# Fade to black
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(_overlay, "modulate:a", 1.0, duration)
	tween.tween_callback(func(): _show_day_card(day_number, next_scene))

# transition.gd — add at top
static var pending_day_number: int = 0
static var pending_next_scene: String = ""

func _show_day_card(day_number: int, next_scene: String) -> void:
	_overlay.modulate.a = 0.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pending_day_number = day_number
	pending_next_scene = next_scene
	get_tree().change_scene_to_file("res://scenes/days/dayTransition.tscn")
