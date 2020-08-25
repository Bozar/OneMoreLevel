extends "res://library/game_progress/ProgressTemplate.gd"


var _spr_WaveLeft := preload("res://sprite/WaveLeft.tscn")
var _spr_WaveRight := preload("res://sprite/WaveRight.tscn")
var _spr_WaveUp := preload("res://sprite/WaveUp.tscn")
var _spr_WaveDown := preload("res://sprite/WaveDown.tscn")

var _new_StyxData := preload("res://library/npc_data/StyxData.gd").new()

var _wave_sprite: Dictionary
var _wave_tag: Dictionary

var _countdown: int = _new_StyxData.RENEW_MAP


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


func renew_world(pc_x: int, pc_y: int) -> void:
	if _countdown == _new_StyxData.RENEW_MAP:
		_countdown = 0
		_remove_wave()
		_create_wave(pc_x, pc_y)
	_countdown += 1


func _create_wave(pc_x: int, pc_y: int) -> void:
	var wave: int
	var light_range: int = 2
	var top_x: int = _new_DungeonSize.MAX_X - 2
	var top_y: int = 1
	var occupy: Array
	var ground_sprite: Sprite

	occupy = _new_CoordCalculator.get_neighbor(
			_new_DungeonSize.CENTER_X, _new_DungeonSize.CENTER_Y,
			light_range, true)
	occupy.push_back([top_x, top_y])

	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			if occupy.has([i, j]):
				continue
			wave = _ref_RandomNumber.get_int(0, 4)
			_ref_CreateObject.create(_wave_sprite[wave],
					_new_MainGroupTag.GROUND, _wave_tag[wave],
					i, j)

			ground_sprite = _ref_DungeonBoard.get_sprite(
					_new_MainGroupTag.GROUND, i, j)

			if _new_CoordCalculator.is_inside_range(i, j, pc_x, pc_y,
					_new_StyxData.PC_SIGHT):
				ground_sprite.modulate = _new_Palette.DARK
			else:
				ground_sprite.modulate = _new_Palette.BACKGROUND


func _remove_wave() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			_ref_RemoveObject.remove(_new_MainGroupTag.GROUND, i, j)
