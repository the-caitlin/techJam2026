class_name WorldItem
extends PanelContainer

const ITEM_SIZE := Vector2(80, 80)
const WorldItemScene := preload("res://scenes/base UI/world_item.tscn")

@onready var icon: TextureRect = %ItemIcon
@onready var label: Label = %ItemLabel

var data: ItemData = null
var _dragging := false
var _drag_offset := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = SIZE_SHRINK_BEGIN
	size_flags_vertical = SIZE_SHRINK_BEGIN
	custom_minimum_size = ITEM_SIZE

func setup(item_data: ItemData) -> void:
	data = item_data
	label.text = data.name
	if data.icon:
		icon.texture = data.icon
	icon.visible = data.icon != null

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_offset = get_global_mouse_position() - global_position
			z_index = 10
			accept_event()
		else:
			if _dragging:
				_dragging = false
				z_index = 0
				var parent := get_parent()
				if parent and parent.has_method("check_combine_or_place"):
					parent.check_combine_or_place(self)
				accept_event()

	if event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset
		accept_event()

func _make_ghost() -> Control:
	var ghost := PanelContainer.new()
	var hbox := HBoxContainer.new()
	ghost.add_child(hbox)
	if data.icon:
		var tex := TextureRect.new()
		tex.texture = data.icon
		tex.custom_minimum_size = Vector2(32, 32)
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(tex)
	var lbl := Label.new()
	lbl.text = data.name
	hbox.add_child(lbl)
	return ghost

# world_item.gd — add these
func _can_drop_data(_at_position: Vector2, dropped) -> bool:
	return dropped is ItemData

func _drop_data(_at_position: Vector2, dropped) -> void:
	var temp: WorldItem = WorldItemScene.instantiate()
	get_parent().add_child(temp)
	temp.setup(dropped)
	temp.global_position = global_position
	get_parent()._combine(temp, self)
