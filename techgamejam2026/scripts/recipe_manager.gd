extends Node

var recipes: Dictionary = {}  

func register_recipe(recipe: RecipeData) -> void:
	var key := _make_key(recipe.ingredient_a.name, recipe.ingredient_b.name)
	recipes[key] = recipe

func try_combine(a: ItemData, b: ItemData) -> ItemData:
	var key := _make_key(a.name, b.name)
	var recipe := recipes.get(key, null) as RecipeData
	return recipe.result if recipe else null

func get_dialogue(a: ItemData, b: ItemData) -> String:
	var key := _make_key(a.name, b.name)
	var recipe := recipes.get(key, null) as RecipeData
	return recipe.discovery_dialogue if recipe else ""

func _make_key(a_name: String, b_name: String) -> String:
	var parts := [a_name.to_lower(), b_name.to_lower()]
	parts.sort()
	return parts[0] + "|" + parts[1]

func _get_recipe_dialogue(a: ItemData, b: ItemData) -> String:
	return RecipeManager.get_dialogue(a, b)
