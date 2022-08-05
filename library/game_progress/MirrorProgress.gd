extends Game_ProgressTemplate


const CRYSTAL_BASE_Y := [
	Game_MirrorData.CENTER_Y_1,
	Game_MirrorData.CENTER_Y_2,
	Game_MirrorData.CENTER_Y_3,
	Game_MirrorData.CENTER_Y_4,
	Game_MirrorData.CENTER_Y_5,
]
const MAX_REPLENISH := 1

var _spr_Crystal := preload("res://sprite/Crystal.tscn")

# If use a constant array, a seed may generate an invalid and irreproducible
# world if keep pressing `O` enough times.
var _ground_coords := []


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func end_world(_pc_coord: Game_IntCoord) -> void:
	_try_end_game()


func npc_end_world(_pc_coord: Game_IntCoord) -> void:
	_try_end_game()


func remove_trap(_trap: Sprite, _x: int, _y: int) -> void:
	var pc := _ref_DungeonBoard.get_pc()
	var hp := _ref_ObjectData.get_hit_point(pc)
	var crystal_base := _ref_DungeonBoard.get_building_xy(
			Game_DungeonSize.CENTER_X, CRYSTAL_BASE_Y[hp])

	_ref_SwitchSprite.set_sprite(crystal_base, Game_SpriteTypeTag.ACTIVE)
	_ref_ObjectData.add_hit_point(pc, 1)

	if _ref_ObjectData.get_hit_point(pc) < Game_MirrorData.MAX_CRYSTAL:
		_replenish_crystal()


func _replenish_crystal() -> void:
	var pc_pos := _ref_DungeonBoard.get_pc_coord()
	var mirror_pos := Game_CoordCalculator.get_mirror_image_xy(
			pc_pos.x, pc_pos.y, Game_DungeonSize.CENTER_X, pc_pos.y)

	if _ground_coords.size() < 1:
		_init_ground_coords()
	Game_WorldGenerator.create_by_coord(_ground_coords,
			MAX_REPLENISH, _ref_RandomNumber, self,
			"_is_valid_ground_coord", [pc_pos, mirror_pos],
			"_create_crystal_here", [])


func _init_ground_coords() -> void:
	var grounds := _ref_DungeonBoard.get_sprites_by_tag(Game_MainTag.GROUND)

	_ground_coords.resize(grounds.size())
	for i in range(0, grounds.size()):
		_ground_coords[i] = Game_ConvertCoord.sprite_to_coord(grounds[i])


func _is_valid_ground_coord(coord: Game_IntCoord, retry: int, opt_arg: Array) \
		-> bool:
	var pc_pos: Game_IntCoord = opt_arg[0]
	var mirror_pos: Game_IntCoord = opt_arg[1]

	if _ref_DungeonBoard.has_actor(coord):
		if (retry > 0) and (coord.x == pc_pos.x) and (coord.y == pc_pos.y):
			return true
		return false
	else:
		for i in [pc_pos, mirror_pos]:
			if Game_CoordCalculator.is_in_range(coord, i,
					Game_MirrorData.CRYSTAL_DISTANCE):
				return false
	return true


func _create_crystal_here(coord: Game_IntCoord, _arg: Array) -> void:
	_ref_CreateObject.create_trap(_spr_Crystal, Game_SubTag.CRYSTAL, coord)


func _try_end_game() -> void:
	var pc := _ref_DungeonBoard.get_pc()

	if _ref_ObjectData.get_hit_point(pc) >= Game_MirrorData.MAX_CRYSTAL:
		_ref_EndGame.player_win()
