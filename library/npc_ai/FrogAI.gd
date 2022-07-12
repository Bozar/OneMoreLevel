extends Game_AITemplate


const WAIT_HIT_POINT := 1
const CAST_RAY := [[0, 1], [0, -1], [1, 0], [-1, 0]]


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
	var hp := _ref_RandomNumber.get_int(Game_FrogData.MIN_WAIT,
			Game_FrogData.MAX_WAIT)
	_ref_ObjectData.set_hit_point(_self, hp)


func _can_grapple() -> bool:
	var pc := _ref_DungeonBoard.get_pc()

	if _ref_ObjectData.verify_state(pc, Game_StateTag.PASSIVE):
		return false
	elif Game_CoordCalculator.is_in_range(_self_pos, _pc_pos,
			Game_FrogData.ATTACK_RANGE):
		return _path_is_clear()
	return false


func _grapple() -> void:
	var neighbor := Game_CoordCalculator.get_neighbor(_self_pos,
			Game_FrogData.ATTACK_RANGE)

	Game_ArrayHelper.filter_element(neighbor, self, "_filter_grapple", [])
	_ref_SwitchSprite.set_sprite(_self, Game_SpriteTypeTag.ACTIVE)
	for i in neighbor:
		_set_danger_zone(i.x, i.y, true)
	_ref_EndGame.player_lose()


func _random_walk() -> void:
	var neighbor := Game_CoordCalculator.get_neighbor(_self_pos,
			Game_FrogData.ATTACK_RANGE, false)
	var max_distance := Game_CoordCalculator.get_range(_self_pos, _pc_pos)
	var target_pos: Game_IntCoord

	Game_ArrayHelper.filter_element(neighbor, self, "_filter_rand_walk", [])
	if max_distance > Game_FrogData.MID_DISTANCE:
		Game_ArrayHelper.filter_element(neighbor, self,"_filter_by_distance",
				[max_distance])
	if neighbor.size() < 1:
		return

	Game_ArrayHelper.rand_picker(neighbor, 1, _ref_RandomNumber)
	target_pos = neighbor.pop_back()
	_ref_DungeonBoard.move_actor(_self_pos, target_pos)


func _set_danger_zone(x: int, y: int, danger: bool) -> void:
	var ground := _ref_DungeonBoard.get_ground_xy(x, y)

	_ref_DangerZone.set_danger_zone(x, y, danger)
	if _ref_DangerZone.is_in_danger(x, y):
		_ref_SwitchSprite.set_sprite(ground, Game_SpriteTypeTag.ACTIVE)
	else:
		_ref_SwitchSprite.set_sprite(ground, Game_SpriteTypeTag.DEFAULT)


func _path_is_clear() -> bool:
	var x: int
	var y: int
	var counter: int

	for i in CAST_RAY:
		x = _self_pos.x
		y = _self_pos.y
		counter = 0
		for _j in range(Game_FrogData.ATTACK_RANGE):
			x += i[0]
			y += i[1]
			if not Game_CoordCalculator.is_inside_dungeon(x, y):
				break
			if _ref_DungeonBoard.has_sprite_with_sub_tag_xy(Game_SubTag.PC,
					x, y):
				if counter > 0:
					return false
				break
			if _ref_DungeonBoard.has_actor_xy(x, y):
				counter += 1
	return true


func _filter_grapple(source: Array, index: int, _opt_arg: Array) -> bool:
	return Game_CoordCalculator.get_range(_pc_pos, source[index]) == 1


func _filter_rand_walk(source: Array, index: int, _opt_arg: Array) -> bool:
	var self_x: int = _self_pos.x
	var self_y: int = _self_pos.y
	var sor_x: int = source[index].x
	var sor_y: int = source[index].y

	if (self_x == sor_x) or (self_y == sor_y) \
			or _ref_DangerZone.is_in_danger(sor_x, sor_y) \
			or _ref_DungeonBoard.has_actor(source[index]):
		return false
	return true


func _filter_by_distance(source: Array, index: int, opt_arg: Array) -> bool:
	var max_range: int = opt_arg[0]
	return Game_CoordCalculator.is_in_range(source[index], _pc_pos, max_range)
