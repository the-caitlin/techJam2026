extends Control

@onready var help_label: Label = %Help
@onready var thanks_label: Label = %Thanks
@onready var glitch_screen: CanvasLayer = $"/root/GlitchScreen"

var help_start_pos: Vector2

func _ready() -> void:
	help_label.add_theme_color_override("font_color", Color.WHITE)
	thanks_label.add_theme_color_override("font_color", Color.WHITE)

	help_label.add_theme_font_size_override("font_size", 150)
	thanks_label.add_theme_font_size_override("font_size", 70)
	
	help_label.visible = false
	thanks_label.visible = false
	
	help_start_pos = help_label.position
	
	_play_sequence()

func _play_sequence() -> void:
	# 1. small delay (black screen)
	await get_tree().create_timer(1.0).timeout
	
	# 2. show HELP
	help_label.show()
	
	await get_tree().create_timer(1.5).timeout
	
	# 3. glitch effect (visual only)
	await _fake_glitch()
	
	# 4. switch to thanks
	help_label.hide()
	thanks_label.show()
	
	# 5. optional fade-in
	thanks_label.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(thanks_label, "modulate:a", 1.0, 1.5)

func _fake_glitch() -> void:
	# quick shake + flicker
	for i in range(10):
		help_label.position = help_start_pos + Vector2(
			randi_range(-15, 15),
			randi_range(-15, 15)
		)
		help_label.visible = !help_label.visible
		await get_tree().create_timer(0.05).timeout
	
	help_label.position = help_start_pos
	help_label.visible = true
