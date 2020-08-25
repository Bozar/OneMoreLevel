extends "res://library/init/WorldTemplate.gd"


var _spr_Lighthouse := preload("res://sprite/Lighthouse.tscn")
var _spr_Harbor := preload("res://sprite/Harbor.tscn")
var _spr_WaveLeft := preload("res://sprite/WaveLeft.tscn")
var _spr_WaveRight := preload("res://sprite/WaveRight.tscn")
var _spr_WaveUp := preload("res://sprite/WaveUp.tscn")
var _spr_WaveDown := preload("res://sprite/WaveDown.tscn")

var _wave_sprite: Dictionary
var _wave_tag: Dictionary


func _init(parent_node: Node2D).(parent_node) -> void:
	_wave_sprite = {
		0: _spr_WaveUp,
		1: _spr_WaveRight,
		2: _spr_WaveDown,
		3: _spr_WaveLeft,
	}

	_wave_tag = {
		0: _new_SubGroupTag.WAVE_UP,
		1: _new_SubGroupTag.WAVE_RIGHT,
		2: _new_SubGroupTag.WAVE_DOWN,
		3: _new_SubGroupTag.WAVE_LEFT,
	}


func get_blueprint() -> Array:
	_init_pc()
	_init_building()
	_init_wave()

	return _blueprint


func _init_floor() -> void:
	pass


func _init_pc() -> void:
	var x: int = 1
	var y: int = _new_DungeonSize.MAX_Y - 2

	_add_to_blueprint(_spr_PC,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC, x, y)


func _init_building() -> void:
	var top_x: int = _new_DungeonSize.MAX_X - 2
	var top_y: int = 1
	var light_range: int = 2
	var occupy: Array

	_add_to_blueprint(_spr_Lighthouse,
			_new_MainGroupTag.BUILDING, _new_SubGroupTag.LIGHTHOUSE,
			_new_DungeonSize.CENTER_X, _new_DungeonSize.CENTER_Y)
	_add_to_blueprint(_spr_Harbor,
			_new_MainGroupTag.BUILDING, _new_SubGroupTag.HARBOR,
			top_x, top_y)

	occupy = _new_CoordCalculator.get_neighbor(
			_new_DungeonSize.CENTER_X, _new_DungeonSize.CENTER_Y,
			light_range, true)
	occupy.push_back([top_x, top_y])

	for i in occupy:
		_occupy_position(i[0], i[1])


func _init_wave() -> void:
	var wave: int

	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			if _is_occupied(i, j):
				continue
			wave = _ref_RandomNumber.get_int(0, 4)
			_add_to_blueprint(_wave_sprite[wave],
					_new_MainGroupTag.GROUND, _wave_tag[wave],
					i, j)
