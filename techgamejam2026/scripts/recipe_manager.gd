extends Node

var recipes: Dictionary = {}  
var discovered_items: Array[String] = []

func register_recipe(recipe: RecipeData) -> void:
	var key := _make_key(recipe.ingredient_a.name, recipe.ingredient_b.name)
	recipes[key] = recipe

func try_combine(a: ItemData, b: ItemData) -> ItemData:
	var key := _make_key(a.name, b.name)
	var recipe := recipes.get(key, null) as RecipeData
	if recipe:
		# Track discovery
		if recipe.result.name not in discovered_items:
			discovered_items.append(recipe.result.name)
		return recipe.result
	return null

func get_dialogue(a: ItemData, b: ItemData) -> String:
	var key := _make_key(a.name, b.name)
	var recipe := recipes.get(key, null) as RecipeData
	return recipe.discovery_dialogue if recipe else ""

func get_all_result_names() -> Array[String]:
	var names: Array[String] = []
	for recipe in recipes.values():
		var r := recipe as RecipeData
		if r and r.result.name not in names:
			names.append(r.result.name)
	return names

func all_discovered() -> bool:
	var all_results := get_all_result_names()
	for name in all_results:
		if name not in discovered_items:
			return false
	return true

func reset() -> void:
	discovered_items.clear()

func _make_key(a_name: String, b_name: String) -> String:
	var parts := [a_name.to_lower(), b_name.to_lower()]
	parts.sort()
	return parts[0] + "|" + parts[1]

func _get_recipe_dialogue(a: ItemData, b: ItemData) -> String:
	return get_dialogue(a, b)
