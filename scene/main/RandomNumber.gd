extends Node2D
class_name Game_RandomNumber


var rng_seed: int setget set_rng_seed, get_rng_seed
var _init_seed: int

var _rng := RandomNumberGenerator.new()


# Get an integer from min_int (inclusive) to max_int (exclusive).
func get_int(min_int: int, max_int: int) -> int:
	return _rng.randi_range(min_int, max_int - 1)


func get_percent_chance(chance: int) -> bool:
	return chance > get_int(0, 100)


func shuffle(repeat: int) -> void:
	var __
	for _i in range(repeat):
		__ = get_int(0, 10)


func get_rng_seed() -> int:
	return _init_seed


func set_rng_seed(_rng_seed: int) -> void:
	return


func _on_GameSetting_setting_loaded(
		setting: Game_GameSetting.PlayerSetting) -> void:
	# _rng.seed = 123
	var set_seed: int = setting.rng_seed

	if set_seed > 0:
		_rng.seed = set_seed
	else:
		_rng.randomize()
		_rng.seed = _rng.randi()

	_init_seed = _rng.seed
	print("seed: {0}".format([_rng.seed]))
