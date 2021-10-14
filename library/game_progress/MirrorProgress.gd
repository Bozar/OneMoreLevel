extends Game_ProgressTemplate


const CRYSTAL_BASE_Y: Array = [
	Game_MirrorData.CENTER_Y_1,
	Game_MirrorData.CENTER_Y_2,
	Game_MirrorData.CENTER_Y_3,
	Game_MirrorData.CENTER_Y_4,
	Game_MirrorData.CENTER_Y_5,
]

var _spr_Crystal := preload("res://sprite/Crystal.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func remove_trap(_trap: Sprite, x: int, y: int) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var hp: int = _ref_ObjectData.get_hit_point(pc)
	var crystal_base: Sprite = _ref_DungeonBoard.get_building(
			Game_DungeonSize.CENTER_X, CRYSTAL_BASE_Y[hp])

	_ref_SwitchSprite.switch_sprite(crystal_base, Game_SpriteTypeTag.ACTIVE)
	_ref_ObjectData.add_hit_point(pc, 1)
	_ref_DangerZone.set_danger_zone(x, y, false)

	if _ref_ObjectData.get_hit_point(pc) < Game_MirrorData.MAX_CRYSTAL:
		_replenish_crystal()


func _replenish_crystal() -> void:
	var x: int
	var y: int
	var pc_pos := _ref_DungeonBoard.get_pc_coord()
	var mirror := Game_CoordCalculator.get_mirror_image(
			pc_pos.x, pc_pos.y, Game_DungeonSize.CENTER_X, pc_pos.y)
	var has_npc: int = 0

	while true:
		# x = _ref_RandomNumber.get_int(
		# 	Game_DungeonSize.CENTER_X, Game_DungeonSize.MAX_X)
		x = _ref_RandomNumber.get_x_coord()
		y = _ref_RandomNumber.get_y_coord()

		if Game_CoordCalculator.is_inside_range(x, y, pc_pos.x, pc_pos.y,
				Game_MirrorData.CRYSTAL_DISTANCE):
			continue
		elif Game_CoordCalculator.is_inside_range(x, y, mirror.x, mirror.y,
				Game_MirrorData.CRYSTAL_DISTANCE):
			continue
		elif _ref_DungeonBoard.has_building(x, y):
			continue
		elif _ref_DungeonBoard.has_actor(x, y):
			if has_npc < 100:
				has_npc += 1
				continue
			else:
				_ref_RemoveObject.remove_actor(x, y)
				break
		else:
			break

	_ref_CreateObject.create_trap(_spr_Crystal, Game_SubTag.CRYSTAL, x, y)
	_ref_DangerZone.set_danger_zone(x, y, true)
