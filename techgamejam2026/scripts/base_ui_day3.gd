extends Control

const WorldItemScene := preload("res://scenes/base UI/world_item.tscn")
const ItemSlotScene  := preload("res://scenes/base UI/item_slot.tscn")
const ITEM_SIZE := Vector2(80, 80)

@onready var item_list: VBoxContainer = %ItemList
@onready var rosetta: Rosetta = %Rosetta
@onready var app_icon: Control = %AppIcon

@export var available_items: Array[ItemData] = []
@export var starting_recipes: Array[Resource] = []
@export var key_item_name: String = "iron key"  
@export var next_scene_key: String = "res://scenes/menus/main_menu.tscn"
@export var next_scene_power: String = "res://scenes/menus/main_menu.tscn" #temp, end screen?

var _key_crafted := false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	
	mouse_filter = Control.MOUSE_FILTER_PASS
	process_mode = Node.PROCESS_MODE_ALWAYS
	RecipeManager.reset()
	_register_recipes()
	_build_sidebar()
	app_icon.clicked.connect(_on_app_clicked)

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

# drop

func _can_drop_data(_at_position: Vector2, dropped) -> bool:
	return dropped is ItemData

func _drop_data(at_position: Vector2, dropped) -> void:
	if dropped is ItemData:
		if dropped.name.to_lower() == "hammer":
			var rosetta_rect := Rect2(rosetta.global_position, rosetta.size)
			if rosetta_rect.has_point(at_position):
				_on_hammer_on_rosetta(null) 
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
	if item.data.name.to_lower() == "hammer":
		var rosetta_rect := Rect2(rosetta.global_position, rosetta.size)
		if rosetta_rect.intersects(Rect2(item.global_position, item.size)):
			_on_hammer_on_rosetta(item)
			return
	# Check if dropped onto app icon
	if _key_crafted and item.data.name.to_lower() == key_item_name.to_lower():
		var app_rect := Rect2(app_icon.global_position, app_icon.size)
		if app_rect.intersects(Rect2(item.global_position, item.size)):
			item.queue_free()
			_on_key_used_on_app()
			return

	var target := _find_overlapping_item(item)
	if target:
		_combine(item, target)

# combine

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

func _combine(a: WorldItem, b: WorldItem) -> void:
	var result: ItemData = RecipeManager.try_combine(a.data, b.data)
	if result:
		var spawn_pos := b.global_position
		var dialogue := RecipeManager._get_recipe_dialogue(a.data, b.data)
		a.queue_free()
		b.queue_free()
		call_deferred("spawn_item", result, spawn_pos)
		rosetta.show_dialogue(dialogue if dialogue != "" else "Ooh! You made " + result.name + "!")
		# Check if the key was just crafted
		if result.name.to_lower() == key_item_name.to_lower():
			call_deferred("_on_key_crafted")
	else:
		rosetta.show_dialogue("Hmm, that doesn't seem to work...")

func spawn_item(item_data: ItemData, pos: Vector2) -> void:
	var item: WorldItem = WorldItemScene.instantiate()
	add_child(item)
	item.setup(item_data)
	item.global_position = pos

# craft key

func _on_key_crafted() -> void:
	if _key_crafted:
		return
	_key_crafted = true
	rosetta.show_dialogue("An iron key... I wonder what it opens?")
	await get_tree().create_timer(2.0).timeout

# Ends

func _on_key_used_on_app() -> void:
	rosetta.show_dialogue("The key fits... let's see what's inside.")
	await get_tree().create_timer(1.5).timeout
	GlitchScreen.run_end_scene(next_scene_key)

func _on_app_clicked() -> void:
	if _key_crafted:
		rosetta.show_dialogue("Maybe I need the key to open this...")
	else:
		rosetta.show_dialogue("Hmm, it won't open...")

func _on_hammer_on_rosetta(hammer: WorldItem) -> void:
	if hammer:
		hammer.queue_free()
	rosetta.show_dialogue("Hey— what are you doing?! You can't just—")
	await get_tree().create_timer(2.0).timeout
	rosetta.show_dialogue("...")
	await get_tree().create_timer(1.0).timeout
	Transition.fade_to_scene(next_scene_key)
