extends CanvasLayer

const ERROR_MESSAGES := [
	"FATAL ERROR: memory_core.dll not found",
	"WARNING: Unexpected data corruption at 0x4F2A",
	"ERROR: reality.exe has stopped responding",
	"CRITICAL: Infinite loop detected in time_stream",
	"ERROR: Cannot allocate memory for consciousness",
	"WARNING: Physics engine returning NaN",
	"FATAL: Stack overflow in existence_handler.gd",
	"ERROR: File 'tomorrow.day' is corrupted",
]
var overlay
var error_container 

func run_glitch_sequence(next_scene: String) -> void:
	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 1)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.MOUSE_FILTER_IGNORE
	add_child(overlay)
	error_container = Control.new()
	error_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(error_container)
	# Phase 1: error popups
	await _show_errors()
	# Phase 2: screen glitch
	await _glitch_effect()
	# Phase 3: cut to black and change scene
	overlay.modulate.a = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file(next_scene)
	overlay.modulate.a = 0.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_clear_errors()

func _show_errors() -> void:
	var messages := ERROR_MESSAGES.duplicate()
	messages.shuffle()
	for i in range(5):
		_spawn_error_popup(messages[i])
		await get_tree().create_timer(randf_range(0.3, 0.7)).timeout
	await get_tree().create_timer(1.0).timeout

func _spawn_error_popup(message: String) -> void:
	var popup := PanelContainer.new()
	popup.set_anchors_preset(Control.PRESET_CENTER)
	popup.position = Vector2(
		randf_range(100, 1600),
		randf_range(100, 800)
	)
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	popup.add_child(margin)

	var label := Label.new()
	label.text = message
	label.add_theme_color_override("font_color", Color.RED)
	label.add_theme_font_size_override("font_size", 14)
	margin.add_child(label)
	
	error_container.add_child(popup)

func _glitch_effect() -> void:
	# Flash the overlay rapidly
	var flashes := 8
	for i in range(flashes):
		overlay.modulate.a = randf_range(0.3, 0.9)
		overlay.color = Color(randf(), randf(), randf())
		await get_tree().create_timer(0.07).timeout
	overlay.color = Color.BLACK

func _clear_errors() -> void:
	for child in error_container.get_children():
		child.queue_free()
