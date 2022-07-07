extends Node2D
class_name Game_RandomNumber


var rng_seed: int setget set_rng_seed, get_rng_seed

var _ref_GameSetting: Game_GameSetting

var _init_seed: int
var _rng := RandomNumberGenerator.new()


# Get an integer from min_int (inclusive) to max_int (exclusive).
func get_int(min_int: int, max_int: int) -> int:
	return _rng.randi_range(min_int, max_int - 1)


func get_percent_chance(chance: int) -> bool:
	return chance > get_int(0, 100)


func get_x_coord() -> int:
	return get_int(0, Game_DungeonSize.MAX_X)


func get_y_coord() -> int:
	return get_int(0, Game_DungeonSize.MAX_Y)


func get_dungeon_coord() -> Game_IntCoord:
	return Game_IntCoord.new(get_x_coord(), get_y_coord())


func shuffle(repeat: int) -> void:
	var __
	for _i in range(repeat):
		__ = get_int(0, 10)


func get_rng_seed() -> int:
	return _init_seed


func set_rng_seed(_rng_seed: int) -> void:
	return


func _on_GameSetting_setting_loaded() -> void:
	# _rng.seed = 123
	_init_seed = _ref_GameSetting.get_rng_seed()

	while _init_seed <= 0:
		_rng.randomize()
		_init_seed = _rng.randi()

	_rng.seed = _init_seed
	print("seed: {0}".format([_init_seed]))


func _on_GameSetting_setting_saved(save_data: Game_TransferData,
		save_tag: int) -> void:
	if save_tag == Game_SaveTag.REPLAY_DUNGEON:
		save_data.overwrite_rng_seed = get_rng_seed()
	else:
		save_data.overwrite_rng_seed = 0
