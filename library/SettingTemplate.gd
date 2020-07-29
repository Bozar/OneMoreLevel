extends Node2D
class_name Game_SettingTemplate


var _wizard: bool
var _seed: int
var _world: String


func _init(wizard_mode: bool, rng_seed: int, world_tag: String) -> void:
	_wizard = wizard_mode
	_seed = rng_seed
	_world = world_tag


func get_wizard_mode() -> bool:
	return _wizard


func get_seed() -> int:
	return _seed


func get_world_tag() -> String:
	return _world
