extends CanvasLayer

var error_textures: Array[Texture2D] = [
	preload("res://assets/errors/error1.png"),
	preload("res://assets/errors/error2.png"),
	preload("res://assets/errors/error3.png"),
	preload("res://assets/errors/error4.png"),
	preload("res://assets/errors/error5.png"),
	preload("res://assets/errors/error6.png"),
]
var overlay
var error_container 

func run_glitch_sequence(next_scene: String) -> void:
	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 1)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE  
	add_child(overlay)
	error_container = Control.new()
	error_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(error_container)

	await _show_errors()
	await _glitch_effect()

	# Cut to black
	overlay.modulate.a = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	await get_tree().create_timer(0.3).timeout
	
	#clean before switch
	_clear_errors()
	overlay.queue_free()
	overlay = null
	
	for child in get_children():
		child.queue_free()
	
	await get_tree().process_frame  
	Transition.fade_to_day(2, next_scene)

func _show_errors() -> void:
	var textures := error_textures.duplicate()
	textures.shuffle()
	for i in textures.size():
		_spawn_error_image(textures[i])
		await get_tree().create_timer(randf_range(0.3, 0.7)).timeout
	await get_tree().create_timer(1.0).timeout

func _spawn_error_image(texture: Texture2D) -> void:
	var img := TextureRect.new()
	img.texture = texture
	img.custom_minimum_size = Vector2(500, 500)  
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Random position on screen
	img.position = Vector2(
		randf_range(50, 1400),
		randf_range(100, 800)
	)
	error_container.add_child(img)

func _spawn_error_popup(message: String) -> void:
	var popup := PanelContainer.new()
	popup.set_anchors_preset(Control.PRESET_CENTER)
	popup.position = Vector2(
		randf_range(-500, 200),
		randf_range(-400, 300)
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
	label.add_theme_font_size_override("font_size", 32)
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

func run_end_scene(next_scene: String):
	get_tree().change_scene_to_file(next_scene)
