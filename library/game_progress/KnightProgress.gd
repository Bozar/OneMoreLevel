extends "res://library/game_progress/ProgressTemplate.gd"


var _spr_Knight := preload("res://sprite/Knight.tscn")
var _spr_KnightCaptain := preload("res://sprite/KnightCaptain.tscn")
var _spr_KnightBoss := preload("res://sprite/KnightBoss.tscn")

var _new_KnightData := preload("res://library/npc_data/KnightData.gd").new()

var _dead_captain: int = 0
var _spawn_captain: bool = false
var _spawn_boss: bool = false
var _pc_x: int
var _pc_y: int
var _counter: Sprite
var _switch_number: Array


func _init(parent_node: Node2D).(parent_node) -> void:
	_switch_number = [
		_new_SpriteTypeTag.ONE, _new_SpriteTypeTag.TWO, _new_SpriteTypeTag.THREE
	]


func renew_world(pc_x: int, pc_y: int) -> void:
	var spawn: int
	var encirclement: Array
	var spawn_nearby: Array
	_pc_x = pc_x
	_pc_y = pc_y

	if _spawn_captain:
		for _i in range(_new_KnightData.MAX_CAPTAIN - 1):
			_spawn_npc(_spr_KnightCaptain, _new_SubGroupTag.KNIGHT_CAPTAIN)
		_spawn_captain = false
	elif _spawn_boss:
		_spawn_npc(_spr_KnightBoss, _new_SubGroupTag.KNIGHT_BOSS)
		_spawn_boss = false

	if _ref_Schedule.count_npc() > _new_KnightData.START_RESPAWN:
		return
	spawn = _ref_RandomNumber.get_int(1, _new_KnightData.MAX_RESPAWN)

	if _is_too_sparse(_pc_x, _pc_y):
		encirclement = _get_encirclement(_pc_x, _pc_y)
		if encirclement.size() > 0:
			spawn_nearby = encirclement[_ref_RandomNumber.get_int(
					0, encirclement.size())]
			_ref_CreateObject.create(_spr_Knight, _new_MainGroupTag.ACTOR,
					_new_SubGroupTag.KNIGHT, spawn_nearby[0], spawn_nearby[1])
			spawn -= 1

	for _i in range(spawn):
		_spawn_npc(_spr_Knight, _new_SubGroupTag.KNIGHT)


func remove_actor(actor: Sprite, _x: int, _y: int) -> void:
	if not actor.is_in_group(_new_SubGroupTag.KNIGHT_CAPTAIN):
		return

	_dead_captain += 1
	if _dead_captain == 1:
		_spawn_captain = true
		_spawn_boss = false
	elif _dead_captain == _new_KnightData.MAX_CAPTAIN:
		_spawn_captain = false
		_spawn_boss = true

	if _counter == null:
		_counter = _ref_DungeonBoard.get_sprites_by_tag(
				_new_SubGroupTag.COUNTER)[0]
	_ref_SwitchSprite.switch_sprite(_counter, _switch_number[_dead_captain - 1])


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


func _is_too_sparse(x: int, y: int) -> bool:
	var actor: int = 0
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			x, y, _new_KnightData.SIGHT)

	for i in neighbor:
		if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, i[0], i[1]):
			actor += 1
	return actor < _new_KnightData.MIN_NEIGHBOR


func _get_encirclement(x: int, y: int) -> Array:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			x, y, _new_KnightData.ENCIRCLEMENT)
	var candidate: Array = []

	for i in neighbor:
		if _is_occupied(i[0], i[1]) or _is_close_to_pc(i[0], i[1]):
			continue
		candidate.push_back(i)
	return candidate
