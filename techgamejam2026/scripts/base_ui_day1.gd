extends Control

const WorldItemScene := preload("res://scenes/base UI/world_item.tscn")
const ItemSlotScene  := preload("res://scenes/base UI/item_slot.tscn")

@onready var item_list: VBoxContainer = %ItemList
@onready var rosetta: Rosetta = %Rosetta
@onready var app_icon: Control = %AppIcon

@export var available_items: Array[ItemData] = []
@export var starting_recipes: Array[Resource] = []
@export var next_scene: String = "res://scenes/days/day2.tscn"

@onready var glitch_screen: CanvasLayer = $"/root/GlitchScreen"

const ITEM_SIZE := Vector2(80, 80)
var _app_spawned := false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	mouse_filter = Control.MOUSE_FILTER_PASS
	process_mode = Node.PROCESS_MODE_ALWAYS
	var bg := %Background
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.size = size
	_register_recipes()
	_build_sidebar()
	app_icon.hide()
	app_icon.clicked.connect(_on_app_clicked)

func _build_sidebar() -> void:
	for item in available_items:
		var slot: ItemSlot = ItemSlotScene.instantiate()
		item_list.add_child(slot)
		slot.setup(item)

func _register_recipes() -> void:
	for recipe in starting_recipes:
		var r := recipe as RecipeData
		if r:
			RecipeManager.register_recipe(r)

func _can_drop_data(_at_position: Vector2, dropped) -> bool:
	return dropped is ItemData

func _drop_data(at_position: Vector2, dropped) -> void:
	if dropped is ItemData:
		var target := _find_item_at_position(at_position)
		if target:
			var temp: WorldItem = WorldItemScene.instantiate()
			add_child(temp)
			temp.setup(dropped)
			temp.global_position = target.global_position
			_combine(temp, target)
		else:
			spawn_item(dropped, at_position)

func check_combine_or_place(item: WorldItem) -> void:
	var target := _find_overlapping_item(item)
	if target:
		_combine(item, target)

func _find_overlapping_item(item: WorldItem) -> WorldItem:
	var item_rect := Rect2(item.global_position, item.size)
	for child in get_children():
		if child == item or not child is WorldItem:
			continue
		if item_rect.intersects(Rect2(child.global_position, child.size)):
			return child
	return null

func _find_item_at_position(pos: Vector2) -> WorldItem:
	for child in get_children():
		if child is WorldItem:
			if Rect2(child.global_position, child.size).has_point(pos):
				return child
	return null

func _combine(a: WorldItem, b: WorldItem) -> void:
	var result: ItemData = RecipeManager.try_combine(a.data, b.data)
	if result:
		var spawn_pos := b.global_position
		var dialogue := RecipeManager.get_dialogue(a.data, b.data)
		a.queue_free()
		b.queue_free()
		call_deferred("spawn_item", result, spawn_pos)
		rosetta.show_dialogue(dialogue if dialogue != "" else "Ooh! You made " + result.name + "!")
		call_deferred("_check_all_discovered")
	else:
		rosetta.show_dialogue("Hmm, that doesn't seem to work...")

func _check_all_discovered() -> void:
	if _app_spawned:
		return
	if RecipeManager.all_discovered():
		_app_spawned = true
		rosetta.show_dialogue("Wow, that was fast! Looks like that's all the combinations for today!")
		await get_tree().create_timer(2.0).timeout
		_spawn_app()

func _spawn_app() -> void:
	# Place app icon in bottom left area, above companion
	app_icon.position = Vector2(20, size.y - 200)
	app_icon.show()
	# Little pop-in animation
	app_icon.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(app_icon, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_app_clicked() -> void:
	glitch_screen.show()
	glitch_screen.run_glitch_sequence(next_scene)

func spawn_item(item_data: ItemData, pos: Vector2) -> void:
	var item: WorldItem = WorldItemScene.instantiate()
	add_child(item)
	item.setup(item_data)
	item.global_position = pos
