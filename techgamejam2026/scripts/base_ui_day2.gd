extends Control

const WorldItemScene := preload("res://scenes/base UI/world_item.tscn")
const ItemSlotScene  := preload("res://scenes/base UI/item_slot.tscn")
const ITEM_SIZE := Vector2(80, 80)

@onready var item_list: VBoxContainer = %ItemList
@onready var rosetta: Rosetta = %Rosetta
@onready var app_icon: Control = %AppIcon

@export var available_items: Array[ItemData] = []
@export var starting_recipes: Array[Resource] = []

@export var pen2_item: ItemData = null
@export var paper2_item: ItemData = null
@export var next_scene: String = "res://scenes/days/day3.tscn"

enum Day2State {
	CRAFTING,        
	ID_CRAFTED,      # id made
	KEY_CRAFTED,     # drawn key made
}

var _state: Day2State = Day2State.CRAFTING

func _ready() -> void:
	for child in GlitchScreen.get_children():
		print("  ", child.name, " : ", child.get_class(), " mouse_filter: ", child.get("mouse_filter"))
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	mouse_filter = Control.MOUSE_FILTER_PASS
	process_mode = Node.PROCESS_MODE_ALWAYS
	RecipeManager.reset()
	_register_recipes()
	_build_sidebar()
	print("Day2 mouse_filter: ", mouse_filter)
	print("Day2 size: ", size)

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

# drop

func _can_drop_data(_at_position: Vector2, dropped) -> bool:
	return dropped is ItemData

func _drop_data(at_position: Vector2, dropped) -> void:
	if dropped is ItemData:
		if _state == Day2State.ID_CRAFTED and dropped.name.to_lower() == "drawn key":
			var app_rect := Rect2(app_icon.global_position, app_icon.size)
			if app_rect.has_point(at_position):
				# Spawn it briefly then trigger cinematic
				var temp: WorldItem = WorldItemScene.instantiate()
				add_child(temp)
				temp.setup(dropped)
				temp.global_position = at_position
				_on_drawn_key_used_on_app(temp)
				return

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
	if _state == Day2State.ID_CRAFTED and item.data.name.to_lower() == "paper key":
		var app_rect := Rect2(app_icon.global_position, app_icon.size)
		if app_rect.intersects(Rect2(item.global_position, item.size)):
			_on_drawn_key_used_on_app(item)
			return
	var target := _find_overlapping_item(item)
	if target:
		_combine(item, target)

func _find_overlapping_item(item: WorldItem) -> WorldItem:
	var item_rect := Rect2(item.global_position, item.size)
	for child in get_children():
		if child == item:
			continue
		if child is WorldItem:
			if item_rect.intersects(Rect2(child.global_position, child.size)):
				return child
	return null

func _find_item_at_position(pos: Vector2) -> WorldItem:
	for child in get_children():
		if child is WorldItem:
			if Rect2(child.global_position, child.size).has_point(pos):
				return child
	return null

# combine

func _combine(a: WorldItem, b: WorldItem) -> void:
	var result: ItemData = RecipeManager.try_combine(a.data, b.data)
	if result:
		var spawn_pos := b.global_position
		var dialogue := RecipeManager._get_recipe_dialogue(a.data, b.data)
		a.queue_free()
		b.queue_free()
		call_deferred("spawn_item", result, spawn_pos)
		rosetta.show_dialogue(dialogue if dialogue != "" else "Ooh! You made " + result.name + "!")
		call_deferred("_check_state", result)
	else:
		rosetta.show_dialogue("Hmm, that doesn't seem to work...")

func spawn_item(item_data: ItemData, pos: Vector2) -> void:
	var item: WorldItem = WorldItemScene.instantiate()
	add_child(item)
	item.setup(item_data)
	item.global_position = pos

# state machine

func _check_state(result: ItemData) -> void:
	match _state:
		Day2State.CRAFTING:
			if result.name.to_lower() == "id":
				_on_id_crafted()
		Day2State.ID_CRAFTED:
			if result.name.to_lower() == "drawn key":
				_on_drawn_key_crafted()

func _on_id_crafted() -> void:
	_state = Day2State.ID_CRAFTED
	#_clear_all_world_items()
	await rosetta.say("My name's not actually rosetta...")
	await rosetta.say("It's Max. Max Fuller. Nice to meet you.") 
	await rosetta.say("Hey, by the way, would you mind trying to help me open that file? I appear to have lost my key.")
	_repopulate_sidebar_phase2()
	await get_tree().create_timer(0.3).timeout

func _on_drawn_key_crafted() -> void:
	_state = Day2State.ID_CRAFTED
	# Just show the app icon, wait for player to use key on it
	app_icon.show()
	app_icon.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(app_icon, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_drawn_key_used_on_app(key_item: WorldItem) -> void:
	_state = Day2State.KEY_CRAFTED
	# Disable all input during cinematic
	mouse_filter = Control.MOUSE_FILTER_STOP
	await rosetta.say("What?? It doesn't fit...")
	await rosetta.say("There must be a way, let me try!")

	# Move key toward Rosetta
	var key_tween := create_tween()
	key_tween.tween_property(key_item, "global_position", rosetta.global_position + Vector2(20, 0), 0.8).set_trans(Tween.TRANS_SINE)
	await key_tween.finished

	# Small pause
	await get_tree().create_timer(0.3).timeout

	# Move key and Rosetta toward app icon together
	var app_pos := app_icon.global_position
	var move_tween := create_tween().set_parallel(true)
	move_tween.tween_property(key_item, "global_position", app_pos, 0.8).set_trans(Tween.TRANS_SINE)
	move_tween.tween_property(rosetta, "global_position", app_pos, 0.8).set_trans(Tween.TRANS_SINE)
	await move_tween.finished

	await get_tree().create_timer(0.3).timeout

	# Cut to black and transition
	Transition.fade_to_day(3, next_scene)

func _rosetta_touches_key() -> void:
	# Clear remaining world items
	_clear_all_world_items()
	# Short pause then black out and transition
	await get_tree().create_timer(0.5).timeout
	Transition.fade_to_scene(next_scene, 1.2)

# helpers

func _clear_all_world_items() -> void:
	for child in get_children():
		if child is WorldItem:
			if child == app_icon:
				continue
			child.queue_free()

func _repopulate_sidebar_phase2() -> void:
	# Clear existing sidebar slots
	for child in item_list.get_children():
		child.queue_free()
	# Add pen2 and paper2
	for item_data in [pen2_item, paper2_item]:
		if item_data:
			var slot: ItemSlot = ItemSlotScene.instantiate()
			item_list.add_child(slot)
			slot.setup(item_data)
