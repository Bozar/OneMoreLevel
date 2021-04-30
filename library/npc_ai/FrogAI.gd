extends Game_AITemplate


const WAIT_HIT_POINT: int = 1
const CAST_RAY: Array = [[0, 1], [0, -1], [1, 0], [-1, 0]]


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	if _ref_ObjectData.get_hit_point(_self) > 0:
		_ref_ObjectData.subtract_hit_point(_self, WAIT_HIT_POINT)
	else:
		_reset_hit_point()
		if _can_grapple():
			_grapple()
		else:
			_random_walk()


func _reset_hit_point() -> void:
	var hp: int = _ref_RandomNumber.get_int(
			Game_FrogData.MIN_WAIT, Game_FrogData.MAX_WAIT)
	_ref_ObjectData.set_hit_point(_self, hp)


func _can_grapple() -> bool:
	var self_x: int = _self_pos[0]
	var self_y: int = _self_pos[1]
	var pc_x: int = _pc_pos[0]
	var pc_y: int = _pc_pos[1]
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _ref_ObjectData.verify_state(pc, Game_ObjectStateTag.PASSIVE):
		return false
	elif _new_CoordCalculator.is_inside_range(self_x, self_y, pc_x, pc_y,
			Game_FrogData.ATTACK_RANGE):
		return _path_is_clear()
	return false


func _grapple() -> void:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			_self_pos[0], _self_pos[1], Game_FrogData.ATTACK_RANGE)
	var pc_move: Array = _new_CoordCalculator.get_neighbor(
			_pc_pos[0], _pc_pos[1], 1, true)

	_new_ArrayHelper.filter_element(neighbor, self, "_filter_grapple",
			[pc_move])
	_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.ACTIVE)
	for i in neighbor:
		_set_danger_zone(i[0], i[1], true)
	_ref_EndGame.player_lose()


func _random_walk() -> void:
	var x: int = _self_pos[0]
	var y: int = _self_pos[1]
	var max_distance: int = _new_CoordCalculator.get_range(
			x, y, _pc_pos[0], _pc_pos[1])
	var neighbor: Array = _new_CoordCalculator.get_neighbor(x, y, 2, false)

	_new_ArrayHelper.filter_element(neighbor, self, "_filter_rand_walk", [])
	_new_ArrayHelper.duplicate_element(neighbor, self, "_dup_rand_walk",
			[max_distance])
	if neighbor.size() < 1:
		return

	_new_ArrayHelper.rand_picker(neighbor, 1, _ref_RandomNumber)
	x = neighbor[0][0]
	y = neighbor[0][1]
	_ref_DungeonBoard.move_sprite(Game_MainGroupTag.ACTOR,
			_self_pos[0], _self_pos[1], x, y)


func _set_danger_zone(x: int, y: int, danger: bool) -> void:
	var ground: Sprite = _ref_DungeonBoard.get_ground(x, y)

	_ref_DangerZone.set_danger_zone(x, y, danger)
	if _ref_DangerZone.is_in_danger(x, y):
		_ref_SwitchSprite.switch_sprite(ground, _new_SpriteTypeTag.ACTIVE)
	else:
		_ref_SwitchSprite.switch_sprite(ground, _new_SpriteTypeTag.DEFAULT)


func _path_is_clear() -> bool:
	var x: int
	var y: int
	var counter: int

	for i in CAST_RAY:
		x = _self_pos[0]
		y = _self_pos[1]
		counter = 0
		for _j in range(Game_FrogData.ATTACK_RANGE):
			x += i[0]
			y += i[1]
			if not _new_CoordCalculator.is_inside_dungeon(x, y):
				break
			if _ref_DungeonBoard.has_sprite_with_sub_tag(
					Game_MainGroupTag.ACTOR, Game_SubGroupTag.PC, x, y):
				if counter > 0:
					return false
				break
			if _ref_DungeonBoard.has_actor(x, y):
				counter += 1
	return true


func _filter_grapple(source: Array, index: int, opt_arg: Array) -> bool:
	var pc_move: Array = opt_arg[0]
	return source[index] in pc_move


func _filter_rand_walk(source: Array, index: int, _opt_arg: Array) -> bool:
	var self_x: int = _self_pos[0]
	var self_y: int = _self_pos[1]
	var sor_x: int = source[index][0]
	var sor_y: int = source[index][1]

	if (self_x == sor_x) or (self_y == sor_y) \
			or _ref_DangerZone.is_in_danger(sor_x, sor_y) \
			or _ref_DungeonBoard.has_actor(sor_x, sor_y):
		return false
	return true


func _dup_rand_walk(source: Array, index: int, opt_arg: Array) -> int:
	var self_x: int = _self_pos[0]
	var self_y: int = _self_pos[1]
	var sor_x: int = source[index][0]
	var sor_y: int = source[index][1]
	var pc_x: int = _pc_pos[0]
	var pc_y: int = _pc_pos[1]
	var max_distance: int = opt_arg[0]
	var repeat: int = 1
	var swamp: int = 1 if _ref_DungeonBoard.has_sprite_with_sub_tag(
			Game_MainGroupTag.GROUND, Game_SubGroupTag.SWAMP, sor_x, sor_y) \
			else 0

	# If a frog is not too far away from PC, it favors swamp grids.
	if _new_CoordCalculator.is_inside_range(self_x, self_y, pc_x, pc_y,
			Game_FrogData.MID_DISTANCE):
		repeat += swamp
	# If a frog is far away from PC, it favors grids that are closer to PC,
	# especially when the grid is swamp.
	elif _new_CoordCalculator.is_inside_range(sor_x, sor_y, pc_x, pc_y,
			max_distance):
		repeat += 1
		repeat += swamp
	return repeat
