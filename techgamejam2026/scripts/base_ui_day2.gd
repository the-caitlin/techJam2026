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
@export var next_scene: String = "res://scenes/day3.tscn"

enum Day2State {
	CRAFTING,        
	ID_CRAFTED,      # id made
	KEY_CRAFTED,     # drawn key made
}

var _state: Day2State = Day2State.CRAFTING

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	mouse_filter = Control.MOUSE_FILTER_PASS
	process_mode = Node.PROCESS_MODE_ALWAYS
	RecipeManager.reset()
	_register_recipes()
	_build_sidebar()
	app_icon.hide()

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
	# Wait for dialogue to finish then clear world items and repopulate sidebar
	await get_tree().create_timer(4.0).timeout
	_clear_all_world_items()
	await get_tree().create_timer(0.3).timeout
	_repopulate_sidebar_phase2()
	rosetta.show_dialogue("My name's not actually rosetta...")
	rosetta.show_dialogue("It's Max. Max Fuller. Nice to meet you.") 
	rosetta.show_dialogue("Hey, by the way, would you mind trying to help me open that file? I appear to have lost my key.")

func _on_drawn_key_crafted() -> void:
	_state = Day2State.KEY_CRAFTED
	rosetta.show_dialogue("What doesn't fit?? There must be a way, let me try!")
	await get_tree().create_timer(3.0).timeout
	_rosetta_touches_key()

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
