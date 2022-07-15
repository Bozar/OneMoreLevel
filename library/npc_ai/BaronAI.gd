extends Game_AITemplate


const MAX_TRAVEL_DISTANCE := Game_DungeonSize.CENTER_X
const MIN_TRAVEL_DISTANCE := 3

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
	# print(Game_CoordCalculator.get_range(_self_pos, _destination[id]))
	# print("==========")


func _bird_act() -> void:
	var pos: Game_IntCoord
	var is_alert := false

	# The default value is false. Set it to true at the end of PC's turn:
	# BaronProgress._respawn_bird(). Let PC see the bird for at least one turn.
	if not _ref_ObjectData.get_bool(_self):
		return

	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.BANDIT):
		# One of the previous bandits has already alerted the bird.
		if is_alert:
			break
		# The bird might be alerted by a nearby bandit.
		pos = Game_ConvertCoord.sprite_to_coord(i)
		if Game_CoordCalculator.is_in_range(pos, _self_pos,
				Game_BaronData.ALERT_RANGE):
			is_alert = _ref_RandomNumber.get_percent_chance(
					Game_BaronData.BANDIT_ALERT)
	# The bird has a small chance to be alerted when being alone.
	is_alert = is_alert or _ref_RandomNumber.get_percent_chance(
			Game_BaronData.BASE_ALERT)

	if is_alert:
		_ref_RemoveObject.remove_actor(_self_pos, Game_BaronData.TREE_LAYER)


func _get_destination() -> Game_IntCoord:
	var pos: Game_IntCoord

	if _ground_coords.size() == 0:
		_ground_coords = _ref_DungeonBoard.get_sprites_by_tag(
				Game_MainTag.GROUND) + _ref_DungeonBoard.get_sprites_by_tag(
				Game_SubTag.TREE_BRANCH)
		for i in range(0, _ground_coords.size()):
			pos = Game_ConvertCoord.sprite_to_coord(_ground_coords[i])
			_ground_coords[i] = pos

	pos = _self_pos
	Game_ArrayHelper.shuffle(_ground_coords, _ref_RandomNumber)
	for i in _ground_coords:
		if Game_CoordCalculator.is_in_range(_self_pos, i, MAX_TRAVEL_DISTANCE) \
				and Game_CoordCalculator.is_out_of_range(_self_pos, i,
						MIN_TRAVEL_DISTANCE):
			pos = i
			break
	return pos


func _reach_destination(id: int) -> bool:
	return (_self_pos.x == _destination[id].x) \
			and (_self_pos.y == _destination[id].y)


func _is_obstacle(x: int, y: int) -> bool:
	return _ref_DungeonBoard.has_sprite_with_sub_tag_xy(Game_MainTag.BUILDING,
			Game_SubTag.TREE_TRUNK, x, y)


func _is_passable_func(source_array: Array, current_index: int,
		_opt_arg: Array) -> bool:
	var x: int = source_array[current_index].x
	var y: int = source_array[current_index].y
	return not _ref_DungeonBoard.has_actor_xy(x, y)
