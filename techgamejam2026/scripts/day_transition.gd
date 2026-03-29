extends Control

@onready var day_label: Label = %DayLabel
@onready var continue_button: Button = %ContinueButton

var _next_scene: String = ""

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	mouse_filter = Control.MOUSE_FILTER_STOP
	continue_button.pressed.connect(_on_continue_pressed)
	
	# Read from Transition autoload
	day_label.text = "Day " + str(Transition.pending_day_number)
	_next_scene = Transition.pending_next_scene
	
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)

func _on_continue_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file(_next_scene))

func setup(day_number: int, next_scene: String) -> void:
	_next_scene = next_scene
	day_label.text = "Day " + str(day_number)
