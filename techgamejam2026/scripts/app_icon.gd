extends Control

signal clicked

@onready var panel: PanelContainer = $PanelContainer

func _ready() -> void:
	custom_minimum_size = Vector2(80, 90)
	size_flags_horizontal = SIZE_SHRINK_BEGIN
	size_flags_vertical = SIZE_SHRINK_BEGIN
	mouse_filter = Control.MOUSE_FILTER_STOP
	_idle_float()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("clicked")

func _on_mouse_entered() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)

func _on_mouse_exited() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _idle_float() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 6.0, 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y, 1.2).set_trans(Tween.TRANS_SINE)
