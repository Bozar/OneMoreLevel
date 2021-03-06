extends "res://library/game_progress/ProgressTemplate.gd"


const MIRROR_DATA := preload("res://library/npc_data/MirrorData.gd")

const CRYSTAL_BASE_Y: Array = [
	MIRROR_DATA.CENTER_Y_1,
	MIRROR_DATA.CENTER_Y_2,
	MIRROR_DATA.CENTER_Y_3,
	MIRROR_DATA.CENTER_Y_4,
	MIRROR_DATA.CENTER_Y_5,
]

var _spr_Crystal := preload("res://sprite/Crystal.tscn")

var _new_MirrorData := preload("res://library/npc_data/MirrorData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func remove_trap(_trap: Sprite, x: int, y: int) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var hp: int = _ref_ObjectData.get_hit_point(pc)
	var crystal_base: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.BUILDING,
			_new_DungeonSize.CENTER_X, CRYSTAL_BASE_Y[hp])

	_ref_SwitchSprite.switch_sprite(crystal_base, _new_SpriteTypeTag.ACTIVE)
	_ref_ObjectData.add_hit_point(pc, 1)
	_ref_DangerZone.set_danger_zone(x, y, false)

	if _ref_ObjectData.get_hit_point(pc) == _new_MirrorData.MAX_CRYSTAL:
		_ref_EndGame.player_win()
	else:
		_replenish_crystal()


func _replenish_crystal() -> void:
	var x: int
	var y: int
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var pc_pos: Array = _new_ConvertCoord.vector_to_array(pc.position)
	var mirror: Array = _new_CoordCalculator.get_mirror_image(
			pc_pos[0], pc_pos[1], _new_DungeonSize.CENTER_X, pc_pos[1])
	var has_npc: int = 0

	while true:
		# x = _ref_RandomNumber.get_int(
		# 	_new_DungeonSize.CENTER_X, _new_DungeonSize.MAX_X)
		x = _ref_RandomNumber.get_x_coord()
		y = _ref_RandomNumber.get_y_coord()

		if _new_CoordCalculator.is_inside_range(
				x, y, pc_pos[0], pc_pos[1], _new_MirrorData.CRYSTAL_DISTANCE):
			continue
		elif _new_CoordCalculator.is_inside_range(
				x, y, mirror[0], mirror[1], _new_MirrorData.CRYSTAL_DISTANCE):
			continue
		elif _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y):
			continue
		elif _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, x, y):
			if has_npc < 100:
				has_npc += 1
				continue
			else:
				_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR, x, y)
				break
		else:
			break

	_ref_CreateObject.create(_spr_Crystal,
			_new_MainGroupTag.TRAP, _new_SubGroupTag.CRYSTAL, x, y)
	_ref_DangerZone.set_danger_zone(x, y, true)
