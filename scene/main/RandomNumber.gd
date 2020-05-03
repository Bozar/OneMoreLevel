extends Node2D


var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	# _rng.seed = 123
	_rng.randomize()


func get_int(min_int: int, max_int: int) -> int:
	return _rng.randi_range(min_int, max_int)
