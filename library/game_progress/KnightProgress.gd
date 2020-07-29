extends "res://library/game_progress/ProgressTemplate.gd"


const Knight := preload("res://sprite/Knight.tscn")
const KnightCaptain := preload("res://sprite/KnightCaptain.tscn")
const KnightBoss := preload("res://sprite/KnightBoss.tscn")

var _new_KnightData := preload("res://library/npc_data/KnightData.gd").new()

var _dead_captain: int = 0
var _spawn_captain: bool = false
var _spawn_boss: bool = false
var _pc_x: int
var _pc_y: int


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func renew_world(pc_x: int, pc_y: int) -> void:
	var spawn: int
	_pc_x = pc_x
	_pc_y = pc_y

	if _spawn_captain:
		for _i in range(_new_KnightData.MAX_CAPTAIN - 1):
			_spawn_npc(KnightCaptain, _new_SubGroupTag.KNIGHT_CAPTAIN)
		_spawn_captain = false
	elif _spawn_boss:
		_spawn_npc(KnightBoss, _new_SubGroupTag.KNIGHT_BOSS)
		_spawn_boss = false

	if _ref_Schedule.count_npc() < _new_KnightData.START_RESPAWN:
		spawn = _ref_RandomNumber.get_int(1, _new_KnightData.MAX_RESPAWN)
		for _i in range(spawn):
			_spawn_npc(Knight, _new_SubGroupTag.KNIGHT)


func remove_npc(npc: Sprite, _x: int, _y: int) -> void:
	if npc.is_in_group(_new_SubGroupTag.KNIGHT_CAPTAIN):
		_dead_captain += 1

		if _dead_captain == 1:
			_spawn_captain = true
			_spawn_boss = false
		elif _dead_captain == _new_KnightData.MAX_CAPTAIN:
			_spawn_captain = false
			_spawn_boss = true


func _spawn_npc(scene: PackedScene, sub_tag: String) -> void:
	var position: Array
	var x: int = -1
	var y: int = -1

	while _is_occupied(x, y) or _is_close_to_pc(x, y) or _has_neighbor(x, y):
		position = _get_position()
		x = position[0]
		y = position[1]

	_ref_CreateObject.create(scene, _new_MainGroupTag.ACTOR, sub_tag, x, y)


func _get_position() -> Array:
	var x: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
	var y: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)

	return [x, y]


func _is_occupied(x: int, y: int) -> bool:
	return (not _new_CoordCalculator.is_inside_dungeon(x, y)) \
		or _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, x, y) \
		or _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y)


func _is_close_to_pc(x: int, y: int) -> bool:
	return _new_CoordCalculator.is_inside_range(
			x, y, _pc_x, _pc_y, _new_KnightData.SIGHT)


func _has_neighbor(x: int, y: int) -> bool:
	var max_range: int = 2
	var neighbor: Array = _new_CoordCalculator.get_neighbor(x, y, max_range)

	for i in neighbor:
		if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, i[0], i[1]):
			return true
	return false
