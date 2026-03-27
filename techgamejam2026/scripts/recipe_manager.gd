extends Node

var recipes: Dictionary = {}

func register_recipe(a: ItemData, b: ItemData, result: ItemData) -> void:
	var key := _make_key(a.name, b.name)
	recipes[key] = result

func try_combine(a: ItemData, b: ItemData) -> ItemData:
	var key := _make_key(a.name, b.name)
	return recipes.get(key, null)

func _make_key(a_name: String, b_name: String) -> String:
	var parts := [a_name.to_lower(), b_name.to_lower()]
	parts.sort()
	return parts[0] + "|" + parts[1]
