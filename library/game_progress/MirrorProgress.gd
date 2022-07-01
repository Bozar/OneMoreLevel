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
	var crystal_base: Sprite = _ref_DungeonBoard.get_building_xy(
			Game_DungeonSize.CENTER_X, CRYSTAL_BASE_Y[hp])

	_ref_SwitchSprite.set_sprite(crystal_base, Game_SpriteTypeTag.ACTIVE)
	_ref_ObjectData.add_hit_point(pc, 1)
	_ref_DangerZone.set_danger_zone(x, y, false)

	if _ref_ObjectData.get_hit_point(pc) < Game_MirrorData.MAX_CRYSTAL:
		_replenish_crystal()


func _replenish_crystal() -> void:
	var pc_pos := _ref_DungeonBoard.get_pc_coord()
	var mirror := Game_CoordCalculator.get_mirror_image_xy(
			pc_pos.x, pc_pos.y, Game_DungeonSize.CENTER_X, pc_pos.y)
	var grids := []

	_init_dungeon_grids()
	for x in range(0, Game_DungeonSize.MAX_X):
		for y in range(0, Game_DungeonSize.MAX_Y):
			if _ref_DungeonBoard.has_building_xy(x, y) \
					or _ref_DungeonBoard.has_actor_xy(x, y) \
					or Game_CoordCalculator.is_in_range_xy(x, y,
							pc_pos.x, pc_pos.y,
							Game_MirrorData.CRYSTAL_DISTANCE) \
					or Game_CoordCalculator.is_in_range_xy(x, y,
							mirror.x, mirror.y,
							Game_MirrorData.CRYSTAL_DISTANCE):
				DUNGEON_GRIDS[x][y] = true
			else:
				DUNGEON_GRIDS[x][y] = false

	for x in range(0, Game_DungeonSize.MAX_X):
		for y in range(0, Game_DungeonSize.MAX_Y):
			if DUNGEON_GRIDS[x][y]:
				continue
			else:
				grids.push_back(Game_IntCoord.new(x, y))

	if grids.size() == 0:
		grids.push_back(pc_pos)
	else:
		Game_ArrayHelper.rand_picker(grids, 1, _ref_RandomNumber)

	_ref_CreateObject.create_trap(_spr_Crystal, Game_SubTag.CRYSTAL, grids[0])
	_ref_DangerZone.set_danger_zone(grids[0].x, grids[0].y, true)
