extends Game_AITemplate


const ONE_STEP_IN_FOG := 1
const ONE_STEP_OUTSIDE_FOG := 2

var _spr_Counter := preload("res://sprite/Counter.tscn")

var _is_first_turn := true
var _player_lose := false
var _boss_restore := 0


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	var is_boss := false
	var ground: Sprite
	var is_in_fog := []
	var self_is_in_fog: bool
	var pc_is_in_fog: bool
	var add_hit_point: int

	if _self.is_in_group(Game_SubTag.PHANTOM):
		return
	elif _self.is_in_group(Game_SubTag.HOUND_BOSS):
		is_boss = true
		_restore_hit_point()

	for i in [_self_pos, _pc_pos]:
		ground = _ref_DungeonBoard.get_ground(i)
		is_in_fog.push_back(_ref_ObjectData.verify_state(ground,
				Game_StateTag.ACTIVE))
	self_is_in_fog = is_in_fog[0]
	pc_is_in_fog = is_in_fog[1]

	if _can_hit_pc(self_is_in_fog, pc_is_in_fog):
		if is_boss:
			add_hit_point = Game_HoundData.HIT_FROM_BOSS
		else:
			add_hit_point = Game_HoundData.HIT_FROM_HOUND
		if pc_is_in_fog:
			add_hit_point += Game_HoundData.HIT_IN_FOG
		_add_pc_hit_point(add_hit_point)
	elif _can_see_pc(is_boss):
		_hound_approach(self_is_in_fog, pc_is_in_fog)

	if is_boss and (not _player_lose):
		_boss_absorb_fog()
	_switch_sprite()


func _switch_sprite() -> void:
	var pos := Game_ConvertCoord.sprite_to_coord(_self)
	var ground := _ref_DungeonBoard.get_ground(pos)
	var sprite_type: String

	if _ref_ObjectData.verify_state(ground, Game_StateTag.ACTIVE):
		sprite_type = Game_SpriteTypeTag.ACTIVE
	else:
		sprite_type = Game_SpriteTypeTag.DEFAULT
	_ref_SwitchSprite.set_sprite(_self, sprite_type)


func _restore_hit_point() -> void:
	var boss_to_pc: int

	if _is_first_turn:
		_is_first_turn = false
		boss_to_pc = Game_CoordCalculator.get_range(_self_pos, _pc_pos)
		_ref_ObjectData.add_hit_point(_self, boss_to_pc)

	if _boss_restore > Game_HoundData.BOSS_RESTORE_COUNTDOWN:
		_boss_restore = 0
		_ref_ObjectData.add_hit_point(_self, Game_HoundData.BOSS_ADD_HIT_POINT)
	else:
		_boss_restore += 1


func _can_hit_pc(self_is_in_fog: bool, pc_is_in_fog: bool) -> bool:
	if self_is_in_fog != pc_is_in_fog:
		return false
	elif self_is_in_fog:
		return Game_CoordCalculator.is_in_range(_self_pos, _pc_pos,
				ONE_STEP_IN_FOG)
	else:
		return Game_CoordCalculator.is_in_range(_self_pos, _pc_pos,
				ONE_STEP_OUTSIDE_FOG) \
				and (_self_pos.x != _pc_pos.x) \
				and (_self_pos.y != _pc_pos.y)


func _can_see_pc(is_boss: bool) -> bool:
	if is_boss:
		return true
	return Game_CoordCalculator.is_in_range(_self_pos, _pc_pos,
			Game_HoundData.HOUND_SIGHT)


func _hound_approach(self_is_in_fog: bool, pc_is_in_fog: bool) -> void:
	var start_point: Array
	var alternative_start := []
	var one_step: int

	start_point = Game_CoordCalculator.get_neighbor(_pc_pos,
			ONE_STEP_OUTSIDE_FOG)
	Game_ArrayHelper.filter_element(start_point, self,
			"_verify_and_get_start_point", [pc_is_in_fog, alternative_start])
	# PC is in fog and is surrounded by four walls.
	if start_point.size() == 0:
		start_point = alternative_start

	if self_is_in_fog:
		one_step = ONE_STEP_IN_FOG
	else:
		one_step = ONE_STEP_OUTSIDE_FOG

	_approach_pc(start_point, one_step, 1, [self_is_in_fog])


func _is_passable_func(source_array: Array, current_index: int,
		opt_arg: Array) -> bool:
	var x: int = source_array[current_index].x
	var y: int = source_array[current_index].y
	var self_is_in_fog: bool = opt_arg[0]

	if _ref_DungeonBoard.has_actor_xy(x, y):
		return false
	elif self_is_in_fog:
		return Game_CoordCalculator.is_in_range_xy(x, y,
				_self_pos.x, _self_pos.y, 1)
	else:
		if Game_CoordCalculator.is_in_range_xy(x, y,
				_self_pos.x, _self_pos.y, 1):
			return true
		return (x != _self_pos.x) and (y != _self_pos.y)


func _verify_and_get_start_point(source: Array, index: int, opt_arg: Array) \
		-> bool:
	var x: int = source[index].x
	var y: int = source[index].y
	var pc_is_in_fog: bool = opt_arg[0]
	var alternative_start: Array = opt_arg[1]

	if _ref_DungeonBoard.has_building_xy(x, y):
		return false

	if Game_CoordCalculator.is_in_range_xy(x, y, _pc_pos.x, _pc_pos.y, 1) \
			or ((x != _pc_pos.x) and (y != _pc_pos.y)):
		alternative_start.push_back(Game_IntCoord.new(x, y))

	if pc_is_in_fog:
		return Game_CoordCalculator.is_in_range_xy(x, y,
				_pc_pos.x, _pc_pos.y, 1)
	else:
		return (x != _pc_pos.x) and (y != _pc_pos.y)


func _add_pc_hit_point(add_hp: int) -> void:
	var pc := _ref_DungeonBoard.get_pc()
	var pc_hit_point := _ref_ObjectData.get_hit_point(pc)
	var phantoms := _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.PHANTOM)
	var pos: Game_IntCoord

	if phantoms.size() == 0:
		# It should be farily easy to find an available location.
		while true:
			pos = _ref_RandomNumber.get_dungeon_coord()
			if _ref_DungeonBoard.has_building(pos):
				continue
			elif _ref_DungeonBoard.has_actor(pos):
				continue
			elif Game_CoordCalculator.is_in_range(pos, _pc_pos,
					Game_HoundData.MIN_BOSS_DISTANCE):
				continue
			elif Game_CoordCalculator.is_out_of_range(pos, _pc_pos,
					Game_HoundData.MAX_BOSS_DISTANCE):
				continue
			break
		_ref_CreateObject.create_actor(_spr_Counter, Game_SubTag.PHANTOM, pos)
		add_hp = 0

	pc_hit_point += add_hp
	pc_hit_point = min(pc_hit_point, Game_HoundData.MAX_PC_HIT_POINT) as int

	_ref_ObjectData.set_hit_point(pc, pc_hit_point)
	if pc_hit_point == Game_HoundData.MAX_PC_HIT_POINT:
		_player_lose = true
		_ref_EndGame.player_lose()


func _boss_absorb_fog() -> void:
	var pos := Game_ConvertCoord.sprite_to_coord(_self)
	var neighbor := Game_CoordCalculator.get_neighbor(pos,
			Game_HoundData.ABSORB_RANGE, true)
	var ground: Sprite

	for i in neighbor:
		ground = _ref_DungeonBoard.get_ground(i)
		# Change ground hit point but leave state unchanged. Update state in
		# HoundProgress._add_or_remove_fog().
		if (ground == null) or (_ref_ObjectData.verify_state(ground,
				Game_StateTag.DEFAULT)):
			continue
		_ref_ObjectData.subtract_hit_point(ground,
				Game_HoundData.ABSORB_DURATION)
		if _ref_ObjectData.get_hit_point(ground) < 1:
			_ref_ObjectData.set_hit_point(ground, 0)
			_ref_SwitchSprite.set_sprite(ground, Game_SpriteTypeTag.ACTIVE_1)
