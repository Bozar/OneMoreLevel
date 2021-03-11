extends "res://library/game_progress/ProgressTemplate.gd"


var _spr_WormHead := preload("res://sprite/WormHead.tscn")
var _spr_Counter := preload("res://sprite/Counter.tscn")

var _new_DesertData := preload("res://library/npc_data/DesertData.gd").new()

var _remove_sprite: Array
var _respawn_counter: Array = []
var _spice_counter: Sprite


func _init(parent_node: Node2D).(parent_node) -> void:
	_remove_sprite = [
		_new_MainGroupTag.BUILDING, _new_MainGroupTag.TRAP
	]

	for _i in range(_new_DesertData.MAX_WORM):
		_respawn_counter.push_back(-1)


func renew_world(_pc_x: int, _pc_y: int) -> void:
	_try_add_new_worm()
	_try_add_new_counter()


func remove_actor(actor: Sprite, _x: int, _y: int) -> void:
	if not actor.is_in_group(_new_SubGroupTag.WORM_HEAD):
		return

	for i in range(_respawn_counter.size()):
		if _respawn_counter[i] == -1:
			_respawn_counter[i] = _ref_RandomNumber.get_int(
					0, _new_DesertData.MAX_COOLDOWN)
			break


func remove_trap(trap: Sprite, _x: int, _y: int) -> void:
	if trap.is_in_group(_new_SubGroupTag.COUNTER):
		_spice_counter = null


func game_over(_win: bool) -> void:
	if _spice_counter != null:
		_switch_spice_counter()
	.game_over(_win)


func _try_add_new_worm() -> void:
	for i in range(_respawn_counter.size()):
		if _respawn_counter[i] == -1:
			continue

		if _respawn_counter[i] == 0:
			_create_worm_head(false, 0)
		_respawn_counter[i] -= 1


func _try_add_new_counter() -> void:
	if _spice_counter != null:
		_switch_spice_counter()
		return

	var traps: Array = []
	var remove_this: Sprite
	var remove_position: Array

	# 3739777475
	# traps = _ref_DungeonBoard.get_sprites_by_tag(_new_MainGroupTag.TRAP)
	traps = _ref_DungeonBoard.get_sprites_by_tag(_new_SubGroupTag.TREASURE)
	if traps.size() == 0:
		return

	remove_this = traps[_ref_RandomNumber.get_int(0, traps.size())]
	remove_position = _new_ConvertCoord.vector_to_array(remove_this.position)

	_ref_RemoveObject.remove(_new_MainGroupTag.TRAP,
			remove_position[0], remove_position[1])
	_ref_CreateObject.create(_spr_Counter,
			_new_MainGroupTag.TRAP, _new_SubGroupTag.COUNTER,
			remove_position[0], remove_position[1])

	_spice_counter = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.TRAP,
			remove_position[0], remove_position[1])
	_switch_spice_counter()


func _switch_spice_counter() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var type_tag: String = _new_SpriteTypeTag.convert_digit_to_tag(
			_ref_ObjectData.get_hit_point(pc))
	_ref_SwitchSprite.switch_sprite(_spice_counter, type_tag)


func _create_worm_head(stop_loop: bool, avoid_building: int) -> void:
	if stop_loop:
		return

	var x: int
	var y: int
	var neighbor: Array
	var max_retry: int = 3

	x = _ref_RandomNumber.get_x_coord()
	y = _ref_RandomNumber.get_y_coord()
	neighbor = _new_CoordCalculator.get_neighbor(x, y,
			_new_DesertData.WORM_DISTANCE, true)

	for i in neighbor:
		if _ref_DungeonBoard.has_sprite(
				_new_MainGroupTag.ACTOR, i[0], i[1]):
			_create_worm_head(false, avoid_building)
			return

	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y) \
			and (avoid_building < max_retry):
		_create_worm_head(false, avoid_building + 1)
		return

	for j in _remove_sprite:
		if _ref_DungeonBoard.has_sprite(j, x, y):
			_ref_RemoveObject.remove(j, x, y)
	_ref_CreateObject.create(
			_spr_WormHead,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.WORM_HEAD,
			x, y)
	_create_worm_head(true, avoid_building)
