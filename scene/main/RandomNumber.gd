extends Node2D
class_name Game_RandomNumber


var rng_seed: int setget set_rng_seed, get_rng_seed

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	# _rng.seed = 123
	_rng.randomize()
	_rng.seed = _rng.randi()
	print("seed: {0}".format([_rng.seed]))


# Get an integer from min_int (inclusive) to max_int (exclusive).
func get_int(min_int: int, max_int: int) -> int:
	return _rng.randi_range(min_int, max_int - 1)


func get_percent_chance(chance: int) -> bool:
	return chance > get_int(0, 100)


func get_rng_seed() -> int:
	return _rng.seed


func set_rng_seed(_rng_seed: int) -> void:
	return
