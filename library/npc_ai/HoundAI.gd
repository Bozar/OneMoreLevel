extends Game_AITemplate


const INIT_DURATION: int = -1
const ONE_STEP_IN_FOG: int = 1
const ONE_STEP_OUTSIDE_FOG: int = 2

var _spr_Counter := preload("res://sprite/Counter.tscn")

var _boss_duration: int = INIT_DURATION
var _player_lose: bool = false


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	var is_boss: bool = false
	var ground: Sprite
	var is_in_fog: Array = []
	var self_is_in_fog: bool
	var pc_is_in_fog: bool
	var add_hit_point: int

	if _self.is_in_group(Game_SubGroupTag.PHANTOM):
		return
	elif _self.is_in_group(Game_SubGroupTag.HOUND_BOSS):
		is_boss = true
		if not _boss_countdown():
			return

	for i in [_self_pos, _pc_pos]:
		ground = _ref_DungeonBoard.get_ground(i[0], i[1])
		is_in_fog.push_back(_ref_ObjectData.verify_state(ground,
				Game_ObjectStateTag.ACTIVE))
	self_is_in_fog = is_in_fog[0]
	pc_is_in_fog = is_in_fog[1]

	if _can_hit_pc(self_is_in_fog, pc_is_in_fog):
		add_hit_point = Game_HoundData.ADD_PC_HIT_POINT
		# _ref_CountDown.subtract_count(Game_HoundData.LOSE_TURN)
		if pc_is_in_fog:
			add_hit_point = Game_HoundData.ADD_PC_HIT_POINT_IN_FOG
			# _ref_CountDown.subtract_count(Game_HoundData.LOSE_EXTRA_TURN)
		if is_boss:
			add_hit_point += Game_HoundData.ADD_PC_HIT_POINT_FROM_BOSS
		_set_pc_hit_point(add_hit_point)
		# _ref_EndGame.player_lose()
	elif _can_see_pc(is_boss):
		_hound_approach(self_is_in_fog, pc_is_in_fog)

	if is_boss and (not _player_lose):
		_boss_absorb_fog()
	_switch_sprite()


func remove_data(actor: Sprite) -> void:
	if actor.is_in_group(Game_SubGroupTag.HOUND_BOSS):
		_boss_duration = INIT_DURATION


func _switch_sprite() -> void:
	var pos: Array = _new_ConvertCoord.vector_to_array(_self.position)
	var ground: Sprite = _ref_DungeonBoard.get_ground(pos[0], pos[1])
	var sprite_type: String

	if _ref_ObjectData.verify_state(ground, Game_ObjectStateTag.ACTIVE):
		# if _ref_ObjectData.get_hit_point(ground) == 0:
		# 	sprite_type = Game_SpriteTypeTag.ACTIVE_1
		# else:
		# 	sprite_type = Game_SpriteTypeTag.ACTIVE
		sprite_type = Game_SpriteTypeTag.ACTIVE
	else:
		sprite_type = Game_SpriteTypeTag.DEFAULT
	_ref_SwitchSprite.switch_sprite(_self, sprite_type)


func _boss_countdown() -> bool:
	var boss_to_pc: int
	var hit_point: int

	if _boss_duration == INIT_DURATION:
		boss_to_pc = _new_CoordCalculator.get_range(_self_pos[0], _self_pos[1],
				_pc_pos[0], _pc_pos[1])
		_boss_duration = boss_to_pc + Game_HoundData.BOSS_DURATION

	if _boss_duration > 0:
		_boss_duration -= 1
		return true
	else:
		hit_point = _ref_ObjectData.get_hit_point(_self)
		# If boss is hit by PC, its hit point adds by 1 before it is removed.
		# Otherwise add hit point by 1 in HoundProgress.
		# HoundPCAction._try_set_and_get_boss_hit_point().
		# HoundProgress.remove_actor().
		_ref_RemoveObject.remove_actor(_self_pos[0], _self_pos[1])
		# Player wins if boss leaves the third time.
		if hit_point + 1 == Game_HoundData.MAX_BOSS_HIT_POINT:
			_ref_EndGame.player_win()
		return false


func _can_hit_pc(self_is_in_fog: bool, pc_is_in_fog: bool) -> bool:
	if self_is_in_fog != pc_is_in_fog:
		return false
	elif self_is_in_fog:
		return _new_CoordCalculator.is_inside_range(_self_pos[0], _self_pos[1],
				_pc_pos[0], _pc_pos[1], ONE_STEP_IN_FOG)
	else:
		return _new_CoordCalculator.is_inside_range(_self_pos[0], _self_pos[1],
				_pc_pos[0], _pc_pos[1], ONE_STEP_OUTSIDE_FOG) \
						and (_self_pos[0] != _pc_pos[0]) \
						and (_self_pos[1] != _pc_pos[1])


func _can_see_pc(is_boss: bool) -> bool:
	if is_boss:
		return true
	return _new_CoordCalculator.is_inside_range(_self_pos[0], _self_pos[1],
			_pc_pos[0], _pc_pos[1], Game_HoundData.HOUND_SIGHT)


func _hound_approach(self_is_in_fog: bool, pc_is_in_fog: bool) -> void:
	var start_point: Array
	var alternative_start: Array = []
	var one_step: int

	start_point = _new_CoordCalculator.get_neighbor(_pc_pos[0], _pc_pos[1],
			ONE_STEP_OUTSIDE_FOG)
	_new_ArrayHelper.filter_element(start_point, self,
			"_verify_and_get_start_point", [pc_is_in_fog, alternative_start])
	# PC is in fog and is surrounded by four walls.
	if start_point.size() == 0:
		start_point = alternative_start

	if self_is_in_fog:
		one_step = ONE_STEP_IN_FOG
	else:
		one_step = ONE_STEP_OUTSIDE_FOG

	_approach_pc(start_point, one_step, [self_is_in_fog])


func _is_passable_func(source_array: Array, current_index: int,
		opt_arg: Array) -> bool:
	var x: int = source_array[current_index][0]
	var y: int = source_array[current_index][1]
	var self_is_in_fog: bool = opt_arg[0]

	if _ref_DungeonBoard.has_actor(x, y):
		return false
	elif self_is_in_fog:
		return _new_CoordCalculator.is_inside_range(x, y,
				_self_pos[0], _self_pos[1], 1)
	else:
		if _new_CoordCalculator.is_inside_range(x, y,
				_self_pos[0], _self_pos[1], 1):
			return true
		return (x != _self_pos[0]) and (y != _self_pos[1])


func _verify_and_get_start_point(source: Array, index: int, opt_arg: Array) \
		-> bool:
	var x: int = source[index][0]
	var y: int = source[index][1]
	var pc_is_in_fog: bool = opt_arg[0]
	var alternative_start: Array = opt_arg[1]

	if _ref_DungeonBoard.has_building(x, y):
		return false

	if _new_CoordCalculator.is_inside_range(x, y, _pc_pos[0], _pc_pos[1], 1) \
			or ((x != _pc_pos[0]) and (y != _pc_pos[1])):
		alternative_start.push_back([x, y])

	if pc_is_in_fog:
		return _new_CoordCalculator.is_inside_range(x, y,
				_pc_pos[0], _pc_pos[1], 1)
	else:
		return (x != _pc_pos[0]) and (y != _pc_pos[1])


func _set_pc_hit_point(add_hit_point: int) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var pc_hit_point: int = _ref_ObjectData.get_hit_point(pc)
	var find_phantom: Array = _ref_DungeonBoard.get_sprites_by_tag(
			Game_SubGroupTag.PHANTOM)
	var phantom: Sprite
	var x: int
	var y: int
	var new_sprite_type: String

	if find_phantom.size() == 0:
		while true:
			x = _ref_RandomNumber.get_x_coord()
			y = _ref_RandomNumber.get_y_coord()
			if _ref_DungeonBoard.has_building(x, y):
				continue
			elif _ref_DungeonBoard.has_actor(x, y):
				continue
			elif _new_CoordCalculator.is_inside_range(x, y,
					_pc_pos[0], _pc_pos[1], Game_HoundData.MIN_BOSS_DISTANCE):
				continue
			elif not _new_CoordCalculator.is_inside_range(x, y,
					_pc_pos[0], _pc_pos[1], Game_HoundData.MAX_BOSS_DISTANCE):
				continue
			else:
				break
		phantom = _ref_CreateObject.create_and_fetch(_spr_Counter,
				Game_MainGroupTag.ACTOR, Game_SubGroupTag.PHANTOM, x, y)
		add_hit_point = 0
	else:
		phantom = find_phantom[0]

	pc_hit_point += add_hit_point
	pc_hit_point = min(pc_hit_point, Game_HoundData.MAX_PC_HIT_POINT) as int

	_ref_ObjectData.set_hit_point(pc, pc_hit_point)
	new_sprite_type = _new_SpriteTypeTag.convert_digit_to_tag(
			Game_HoundData.MAX_PC_HIT_POINT - pc_hit_point)
	_ref_SwitchSprite.switch_sprite(phantom, new_sprite_type)
	if pc_hit_point == Game_HoundData.MAX_PC_HIT_POINT:
		_player_lose = true
		_ref_EndGame.player_lose()


func _boss_absorb_fog() -> void:
	var hit_point: int = _ref_ObjectData.get_hit_point(_self)
	var pos: Array = _new_ConvertCoord.vector_to_array(_self.position)
	var neighbor: Array = _new_CoordCalculator.get_neighbor(pos[0], pos[1],
			hit_point, true)
	var ground: Sprite

	for i in neighbor:
		ground = _ref_DungeonBoard.get_ground(i[0], i[1])
		# Change ground hit point but leave state unchanged. Update state in
		# HoundProgress._add_or_remove_fog().
		if (ground == null) or (_ref_ObjectData.verify_state(ground,
				Game_ObjectStateTag.DEFAULT)):
			continue
		_ref_ObjectData.subtract_hit_point(ground,
				Game_HoundData.ABSORB_DURATION)
		if _ref_ObjectData.get_hit_point(ground) < 1:
			_ref_ObjectData.set_hit_point(ground, 0)
			_ref_SwitchSprite.switch_sprite(ground, Game_SpriteTypeTag.ACTIVE_1)
