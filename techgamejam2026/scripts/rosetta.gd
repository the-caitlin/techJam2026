class_name Rosetta
extends Control

@onready var sprite: Sprite2D = $Sprite2D
@onready var bubble: PanelContainer = $DialogueBubble
@onready var dialogue_label: Label = $DialogueBubble/MarginContainer/DialogueLabel

# Idle lines for random ambient dialogue
const IDLE_LINES: Array[String] = [
	"Hi, I'm Rosetta! The browser assistant designed to help you navigate this page.",
	"Have you tried combining everything?",
	"Do you need any help?",
	"Some combinations are truly surprising!",
	"Try dragging items to combine them!",
]

var _idle_timer: float = 0.0
var _idle_interval: float = 8.0
var _dialogue_timer: float = 0.0
var _dialogue_duration: float = 4.0
var _showing_dialogue: bool = false

func _ready() -> void:
	bubble.hide()
	bubble.modulate.a = 0.0
	_idle_timer = _idle_interval
	
	# If we want to add animated rosetta in future 
	#if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
	#	sprite.play("idle")

func _process(delta: float) -> void:
	# Idle dialogue timer
	if not _showing_dialogue:
		_idle_timer -= delta
		if _idle_timer <= 0.0:
			var line := IDLE_LINES[randi() % IDLE_LINES.size()]
			show_dialogue(line)
			_idle_timer = _idle_interval + randf_range(-2.0, 4.0)

	# Auto-hide dialogue
	if _showing_dialogue:
		_dialogue_timer -= delta
		if _dialogue_timer <= 0.0:
			hide_dialogue()

func show_dialogue(text: String, duration: float = 4.0) -> void:
	dialogue_label.text = text
	_dialogue_duration = duration
	_dialogue_timer = duration
	_showing_dialogue = true
	bubble.show()
	# Fade in
	var tween := create_tween()
	tween.tween_property(bubble, "modulate:a", 1.0, 0.2)

func hide_dialogue() -> void:
	_showing_dialogue = false
	var tween := create_tween()
	tween.tween_property(bubble, "modulate:a", 0.0, 0.3)
	tween.tween_callback(bubble.hide)
