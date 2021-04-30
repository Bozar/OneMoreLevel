extends Game_ProgressTemplate


const MAX_RETRY: int = 10
const RESET_COUNTER: int = -1

var _spr_WormHead := preload("res://sprite/WormHead.tscn")
var _spr_Counter := preload("res://sprite/Counter.tscn")

var _respawn_counter: Array = []


func _init(parent_node: Node2D).(parent_node) -> void:
	for _i in range(Game_DesertData.MAX_WORM):
		_respawn_counter.push_back(-1)


func end_world(_pc_x: int, _pc_y: int) -> void:
	_try_add_new_worm()


func remove_actor(actor: Sprite, _x: int, _y: int) -> void:
	if not actor.is_in_group(Game_SubGroupTag.WORM_HEAD):
		return

	for i in range(_respawn_counter.size()):
		if _respawn_counter[i] == RESET_COUNTER:
			_respawn_counter[i] = _ref_RandomNumber.get_int(
					Game_DesertData.MIN_COOLDOWN, Game_DesertData.MAX_COOLDOWN)
			break


func remove_building(_building: Sprite, x: int, y: int) -> void:
	_add_or_remove_ground(true, x, y)


func remove_trap(_trap: Sprite, x: int, y: int) -> void:
	_add_or_remove_ground(true, x, y)


func create_building(_building: Sprite, _sub_group: String,
		x: int, y: int) -> void:
	_add_or_remove_ground(false, x, y)


func create_trap(_trap: Sprite, _sub_group: String, x: int, y: int) -> void:
	_add_or_remove_ground(false, x, y)


func _try_add_new_worm() -> void:
	for i in range(_respawn_counter.size()):
		if _respawn_counter[i] == RESET_COUNTER:
			continue
		if _respawn_counter[i] == Game_DesertData.MIN_COOLDOWN:
			_create_worm_head(0)
		_respawn_counter[i] -= 1


func _create_worm_head(retry: int) -> void:
	var x: int
	var y: int
	var neighbor: Array

	x = _ref_RandomNumber.get_x_coord()
	y = _ref_RandomNumber.get_y_coord()
	neighbor = _new_CoordCalculator.get_neighbor(x, y,
			Game_DesertData.WORM_DISTANCE, true)

	for i in neighbor:
		if _ref_DungeonBoard.has_actor(i[0], i[1]):
			_create_worm_head(retry)
			return

	if _has_building_or_trap(x, y) and (retry < MAX_RETRY):
		_create_worm_head(retry + 1)
		return

	_ref_RemoveObject.remove_building(x, y)
	_ref_RemoveObject.remove_trap(x, y)
	_ref_CreateObject.create(_spr_WormHead, Game_MainGroupTag.ACTOR,
			Game_SubGroupTag.WORM_HEAD, x, y)


func _has_building_or_trap(x: int, y: int) -> bool:
	return _ref_DungeonBoard.has_building(x, y) \
			or _ref_DungeonBoard.has_trap(x, y)
