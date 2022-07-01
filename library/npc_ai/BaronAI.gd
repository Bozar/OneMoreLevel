extends Game_AITemplate


const MIN_TRAVEL_DISTANCE := Game_DungeonSize.CENTER_X

var _destination := {}
var _ground_coords := []


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func remove_data(actor: Sprite) -> void:
	var __

	if actor.is_in_group(Game_SubTag.BANDIT):
		__ = _destination.erase(actor.get_instance_id())


func take_action() -> void:
	if _self.is_in_group(Game_SubTag.BANDIT):
		_bandit_act()
	elif _self.is_in_group(Game_SubTag.BIRD):
		_bird_act()


func _bandit_act() -> void:
	var id := _self.get_instance_id()

	if not _destination.has(id) or _reach_destination(id):
		_destination[id] = _get_destination()
	_approach_pc([_destination[id]])

	# print(String(_destination[id].x) + "," + String(_destination[id].y))
	# print(Game_CoordCalculator.get_range(_self_pos.x, _self_pos.y,
	# 		_destination[id].x, _destination[id].y))
	# print("==========")


func _bird_act() -> void:
	var bandits := _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.BANDIT)
	var pos: Game_IntCoord
	var is_alert := false

	for i in bandits:
		pos = Game_ConvertCoord.vector_to_coord(i.position)
		if Game_CoordCalculator.is_inside_range(pos.x, pos.y,
				_self_pos.x, _self_pos.y, Game_BaronData.ALERT_RANGE):
			is_alert = _ref_RandomNumber.get_percent_chance(
					Game_BaronData.BANDIT_ALERT)
			break
	is_alert = is_alert or _ref_RandomNumber.get_percent_chance(
			Game_BaronData.BASE_ALERT)

	if is_alert:
		_ref_RemoveObject.remove_actor(_self_pos.x, _self_pos.y,
				Game_BaronData.TREE_LAYER)


func _get_destination() -> Game_IntCoord:
	var pos: Game_IntCoord

	if _ground_coords.size() == 0:
		_ground_coords = _ref_DungeonBoard.get_sprites_by_tag(
				Game_MainTag.GROUND) + _ref_DungeonBoard.get_sprites_by_tag(
				Game_SubTag.TREE_BRANCH)
		for i in range(0, _ground_coords.size()):
			pos = Game_ConvertCoord.vector_to_coord(_ground_coords[i].position)
			_ground_coords[i] = pos

	Game_ArrayHelper.shuffle(_ground_coords, _ref_RandomNumber)
	for i in _ground_coords:
		if Game_CoordCalculator.get_range(_self_pos.x, _self_pos.y, i.x, i.y) \
				> MIN_TRAVEL_DISTANCE:
			pos = i
			break
		else:
			pos = _self_pos
	return pos


func _reach_destination(id: int) -> bool:
	return (_self_pos.x == _destination[id].x) \
			and (_self_pos.y == _destination[id].y)


func _is_obstacle(x: int, y: int) -> bool:
	return _ref_DungeonBoard.has_sprite_with_sub_tag(Game_SubTag.TREE_TRUNK,
		x, y)


func _is_passable_func(source_array: Array, current_index: int,
		_opt_arg: Array) -> bool:
	var x: int = source_array[current_index].x
	var y: int = source_array[current_index].y
	return not _ref_DungeonBoard.has_actor(x, y)
