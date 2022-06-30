extends Game_AITemplate


var _destination := {}


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
	pass


func _get_destination() -> Game_IntCoord:
	var x := _ref_RandomNumber.get_x_coord()
	var y := _ref_RandomNumber.get_y_coord()

	if _ref_DungeonBoard.has_sprite_with_sub_tag(Game_SubTag.TREE_TRUNK, x, y):
		return _get_destination()
	return Game_IntCoord.new(x, y)


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
