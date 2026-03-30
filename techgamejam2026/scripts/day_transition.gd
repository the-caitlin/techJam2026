extends Control

@onready var background: TextureRect = %Background
@onready var continue_button: TextureButton = %ContinueButton

var _next_scene: String = ""

@export var day_backgrounds: Array[Texture2D] = []

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	mouse_filter = Control.MOUSE_FILTER_STOP
	continue_button.pressed.connect(_on_continue_pressed)

	# Set background based on day number
	var day_index := Transition.pending_day_number - 1
	if day_index >= 0 and day_index < day_backgrounds.size():
		background.texture = day_backgrounds[day_index]

	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)

func _on_continue_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file(Transition.pending_next_scene))

func setup(day_number: int, next_scene: String) -> void:
	_next_scene = next_scene
