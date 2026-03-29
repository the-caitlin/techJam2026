class_name Rosetta
extends Control

@onready var sprite: AnimatedSprite2D = $Sprite2D
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

const INTRO_PHRASES: Array[String] = [
	"Hi, I'm Rosetta! The browser assistant designed to help you navigate this page.",
	"Drag items on top of each other to make new ones",
	"Have fun combining!",
]

var _idle_timer: float = 0.0
var _idle_interval: float = 8.0
var _dialogue_timer: float = 0.0
var _dialogue_duration: float = 4.0
var _showing_dialogue: bool = false

var _done_intro: bool = false

func _ready() -> void:
	bubble.hide()
	bubble.modulate.a = 0.0
	_idle_timer = _idle_interval
	
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")


func _process(delta: float) -> void:
	if not _done_intro: 
		return
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
	var random = randi_range(1, 10)
	
	if random % 2 == 0: 
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("talking"):
			sprite.play("talking")
	else: 
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("spinn"):
			sprite.play("spinn")
	# Fade in
	var tween := create_tween()
	tween.tween_property(bubble, "modulate:a", 1.0, 0.2)

func say(text: String) -> void:
	show_dialogue(text)
	await get_tree().create_timer(_dialogue_duration).timeout

func hide_dialogue() -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	_showing_dialogue = false
	var tween := create_tween()
	tween.tween_property(bubble, "modulate:a", 0.0, 0.3)
	tween.tween_callback(bubble.hide)
	
func intro_dialogue() -> void:
	_done_intro = false
	for phrase in INTRO_PHRASES: 
		show_dialogue(phrase)
		await get_tree().create_timer(3).timeout
	_done_intro = true
