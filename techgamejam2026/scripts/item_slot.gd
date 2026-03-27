class_name ItemSlot
extends PanelContainer

@onready var icon: TextureRect = %ItemIcon
@onready var label: Label = %ItemLabel

var data: ItemData = null

func setup(item_data: ItemData) -> void:
	data = item_data
	label.text = data.name
	if data.icon:
		icon.texture = data.icon
	icon.visible = data.icon != null

func _get_drag_data(_at_position: Vector2) -> Variant:
	var ghost := _make_ghost()
	set_drag_preview(ghost)
	return data  

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
