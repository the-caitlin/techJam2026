extends Control

const WorldItemScene := preload("res://scenes/world_item.tscn")
const ItemSlotScene  := preload("res://scenes/item_slot.tscn")
const ITEM_SIZE := Vector2(80, 80)

@onready var item_list: VBoxContainer = %ItemList
@onready var rosetta: Rosetta = %Rosetta

@export var available_items: Array[ItemData] = []
@export var starting_recipes: Array[Resource] = []

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	var bg := %Background
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.size = size
	
	mouse_filter = Control.MOUSE_FILTER_PASS
	process_mode = Node.PROCESS_MODE_ALWAYS
	_register_recipes()
	_build_sidebar()

# sidebar

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
#sidebar drag and drop 

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
	else:
		pass

func _find_overlapping_item(item: WorldItem) -> WorldItem:
	var item_rect := Rect2(item.global_position, item.size)
	for child in get_children():
		if child == item:
			continue
		if child is WorldItem:
			var other_rect := Rect2(child.global_position, child.size)
			if item_rect.intersects(other_rect):
				return child
	return null

func _combine(a: WorldItem, b: WorldItem) -> void:
	var result: ItemData = RecipeManager.try_combine(a.data, b.data)
	if result:
		var spawn_pos := b.global_position
		# Find the recipe to get its dialogue
		var dialogue := RecipeManager._get_recipe_dialogue(a.data, b.data)
		a.queue_free()
		b.queue_free()
		call_deferred("spawn_item", result, spawn_pos)
		if dialogue != "":
			rosetta.show_dialogue(dialogue)
		else:
			rosetta.show_dialogue("Ooh! You made " + result.name + "!")
	else:
		rosetta.show_dialogue("Hmm, that doesn't seem to work...")

func spawn_item(item_data: ItemData, pos: Vector2) -> void:
	var item: WorldItem = WorldItemScene.instantiate()
	add_child(item)
	item.setup(item_data)
	item.global_position = pos

func _find_item_at_position(pos: Vector2) -> WorldItem:
	for child in get_children():
		if child is WorldItem:
			var rect := Rect2(child.global_position, child.size)
	for child in get_children():
		if child is WorldItem:
			var rect := Rect2(child.global_position, child.size)
			if rect.has_point(pos):
				return child
	return null
