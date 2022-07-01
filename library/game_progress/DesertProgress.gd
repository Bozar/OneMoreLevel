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
	if not actor.is_in_group(Game_SubTag.WORM_HEAD):
		return

	for i in range(_respawn_counter.size()):
		if _respawn_counter[i] == RESET_COUNTER:
			_respawn_counter[i] = _ref_RandomNumber.get_int(
					Game_DesertData.MIN_COOLDOWN, Game_DesertData.MAX_COOLDOWN)
			break


func _try_add_new_worm() -> void:
	for i in range(_respawn_counter.size()):
		if _respawn_counter[i] == RESET_COUNTER:
			continue
		if _respawn_counter[i] == Game_DesertData.MIN_COOLDOWN:
			_create_worm_head(0)
		_respawn_counter[i] -= 1


func _create_worm_head(retry: int) -> void:
	var x: int = _ref_RandomNumber.get_x_coord()
	var y: int = _ref_RandomNumber.get_y_coord()
	var neighbor: Array = Game_CoordCalculator.get_neighbor_xy(x, y,
			Game_DesertData.WORM_DISTANCE, true)
	var head: Sprite

	for i in neighbor:
		if _ref_DungeonBoard.has_actor(i.x, i.y):
			_create_worm_head(retry)
			return
	if _has_building_or_trap(x, y) and (retry < MAX_RETRY):
		_create_worm_head(retry + 1)
		return

	_ref_RemoveObject.remove_building(x, y)
	_ref_RemoveObject.remove_trap(x, y)
	head = _ref_CreateObject.create_and_fetch_actor(_spr_WormHead,
			Game_SubTag.WORM_HEAD, x, y)
	_ref_ObjectData.set_state(head, Game_StateTag.PASSIVE)


func _has_building_or_trap(x: int, y: int) -> bool:
	return _ref_DungeonBoard.has_building(x, y) \
			or _ref_DungeonBoard.has_trap(x, y)
