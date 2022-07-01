extends Game_PCActionTemplate


const HALF_SIGHT_WIDTH := 1
const RAY_DIRECTION := [
	[0, 1],
	[0, -1],
	[1, 0],
	[-1, 0],
]
const HORIZONTAL := 0
const VERTICAL := 1

var _spr_Treasure := preload("res://sprite/Treasure.tscn")
var _spr_Portal := preload("res://sprite/Portal.tscn")

var _counter_sprite: Array = []
var _kill_count: int = Game_RailgunData.MAX_KILL_COUNT
var _ammo: int = Game_RailgunData.MAX_AMMO
var _face_direction: Array = [0, -1]
var _has_found_pillar: bool = false
var _plillar_position: Game_IntCoord


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func set_target_position(direction: String) -> void:
	_face_direction = Game_InputTag.DIRECTION_TO_COORD[direction]
	.set_target_position(direction)


# Switch PC sprite when: PC waits, PC shoots or game ends.
func switch_sprite() -> void:
	pass


func game_over(win) -> void:
	_render_end_game(win)
	_switch_mode(true)


func render_fov() -> void:
	var pos: Game_IntCoord

	_set_render_sprites()
	# A wall sprite will be replaced by pillar sprite in _init_skull_pillar().
	_init_skull_pillar()
	_init_counter()
	_render_counter(_kill_count)

	if _ref_GameSetting.get_show_full_map():
		_render_without_fog_of_war()
		return

	Game_CrossShapedFOV.set_t_shaped_sight(
			Game_DungeonSize.MAX_X, Game_DungeonSize.MAX_Y,
			_source_position.x, _source_position.y,
			_face_direction[0], _face_direction[1],
			HALF_SIGHT_WIDTH,
			Game_RailgunData.PC_FRONT_SIGHT, Game_RailgunData.PC_SIDE_SIGHT,
			self, "_block_line_of_sight", [])

	for mtag in RENDER_SPRITES:
		for i in RENDER_SPRITES[mtag]:
			pos = Game_ConvertCoord.vector_to_coord(i.position)
			match mtag:
				Game_MainTag.ACTOR:
					_set_sprite_color_with_memory(pos.x, pos.y, mtag, false,
							Game_CrossShapedFOV, "is_in_sight")
				Game_MainTag.TRAP:
					_set_sprite_color(pos.x, pos.y, mtag, Game_CrossShapedFOV,
							"is_in_sight")
				_:
					if _do_not_render_building(pos.x, pos.y):
						pass
					else:
						_set_sprite_color_with_memory(pos.x, pos.y, mtag, true,
								Game_CrossShapedFOV, "is_in_sight")


func is_inside_dungeon() -> bool:
	return true


func is_npc() -> bool:
	return _is_aim_mode()


func is_building() -> bool:
	return (not .is_inside_dungeon()) or .is_building()


func wait() -> void:
	_switch_mode(not _is_aim_mode())


func attack() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var x: int = _target_position.x
	var y: int = _target_position.y

	if _ammo < 1:
		return
	_ammo -= 1
	_ammo = max(_ammo, 0) as int
	_ref_ObjectData.add_hit_point(pc, Game_RailgunData.GUN_SHOT_HP)
	_switch_mode(false)

	while Game_CoordCalculator.is_inside_dungeon(x, y) \
			and (not _ref_DungeonBoard.has_building_xy(x, y)):
		if not _ref_DungeonBoard.has_actor_xy(x, y):
			x += _face_direction[0]
			y += _face_direction[1]
			continue

		_ref_RemoveObject.remove_actor_xy(x, y)
		_ref_CreateObject.create_trap_xy(_spr_Treasure, Game_SubTag.TREASURE, x, y)

		_kill_count -= Game_RailgunData.ONE_KILL
		if _ammo == 0:
			_kill_count -= Game_RailgunData.ONE_KILL
		if Game_CoordCalculator.is_in_range_xy(
				_source_position.x, _source_position.y, x, y,
				Game_RailgunData.CLOSE_RANGE):
			_kill_count -= Game_RailgunData.ONE_KILL
		_kill_count = max(_kill_count, 0) as int
		break

	if _kill_count == 0:
		_ref_EndGame.player_win()
	else:
		end_turn = true


func move() -> void:
	if _is_under_attack():
		return
	elif _ref_DungeonBoard.has_actor_xy(_target_position.x, _target_position.y):
		return
	_pc_move()


func interact_with_trap() -> void:
	if _is_under_attack():
		return
	_ref_RemoveObject.remove_trap_xy(_target_position.x, _target_position.y)
	_pc_restore()
	_pc_move()


func _pc_move() -> void:
	_set_move_hit_point()
	_try_find_pillar()
	.move()


func _pc_restore() -> void:
	_ref_CountDown.add_count(Game_RailgunData.RESTORE_TURN)
	_ammo += Game_RailgunData.RESTORE_AMMO
	_ammo = min(_ammo, Game_RailgunData.MAX_AMMO) as int


func _is_checkmate() -> bool:
	if _ammo > 0:
		return false
	return not (_is_passable(HORIZONTAL) or _is_passable(VERTICAL))


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_building_xy(x, y)


func _init_skull_pillar() -> void:
	var building: Array
	var pos: Game_IntCoord
	var neighbor: Array

	if _plillar_position != null:
		return

	building = _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.WALL)
	Game_ArrayHelper.shuffle(building, _ref_RandomNumber)

	for i in building:
		pos = Game_ConvertCoord.vector_to_coord(i.position)
		if Game_CoordCalculator.is_in_range_xy(pos.x, pos.y,
				_source_position.x, _source_position.y,
				Game_DungeonSize.CENTER_X):
			continue

		neighbor = Game_CoordCalculator.get_neighbor_xy(pos.x, pos.y, 1, false)
		for j in neighbor:
			if _ref_DungeonBoard.has_ground_xy(j.x, j.y):
				_ref_RemoveObject.remove_building_xy(pos.x, pos.y)
				_ref_CreateObject.create_building_xy(_spr_Portal,
						Game_SubTag.PILLAR, pos.x, pos.y)
				_plillar_position = pos
				return


func _init_counter() -> void:
	if _counter_sprite.size() == 0:
		for x in range(Game_DungeonSize.MAX_X - Game_RailgunData.COUNTER_WIDTH,
				Game_DungeonSize.MAX_X):
			_counter_sprite.push_back(_ref_DungeonBoard.get_building_xy(
					x, Game_DungeonSize.MAX_Y - 1))
			_ref_Palette.set_dark_color(_counter_sprite.back(),
					Game_MainTag.BUILDING)


func _render_counter(kill: int) -> void:
	var counter: Array = []
	var sprite_type: String

	for _i in range(Game_RailgunData.COUNTER_WIDTH):
		if kill > Game_RailgunData.COUNTER_DIGIT:
			counter.push_front(Game_RailgunData.COUNTER_DIGIT)
		else:
			counter.push_front(kill)
		kill -= Game_RailgunData.COUNTER_DIGIT
		kill = max(kill, 0) as int

	for i in range(counter.size()):
		sprite_type = Game_SpriteTypeTag.convert_digit_to_tag(counter[i])
		_ref_SwitchSprite.set_sprite(_counter_sprite[i], sprite_type)


func _switch_mode(aim_mode: bool) -> void:
	var new_state: int
	var new_sprite: String
	var pc := _ref_DungeonBoard.get_pc()

	if aim_mode:
		new_state = Game_StateTag.ACTIVE
		new_sprite = Game_SpriteTypeTag.convert_digit_to_tag(_ammo)
	else:
		new_state = Game_StateTag.DEFAULT
		new_sprite = Game_SpriteTypeTag.DEFAULT

	_ref_ObjectData.set_state(pc, new_state)
	_ref_SwitchSprite.set_sprite(pc, new_sprite)


func _is_aim_mode() -> bool:
	var pc := _ref_DungeonBoard.get_pc()
	return _ref_ObjectData.verify_state(pc, Game_StateTag.ACTIVE)


func _try_find_pillar() -> void:
	var pillar: Sprite

	if _has_found_pillar:
		return
	_has_found_pillar = Game_CoordCalculator.is_in_range_xy(
			_target_position.x, _target_position.y,
			_plillar_position.x, _plillar_position.y,
			Game_RailgunData.TOUCH_PILLAR)
	if _has_found_pillar:
		pillar = _ref_DungeonBoard.get_building_xy(
				_plillar_position.x, _plillar_position.y)
		_ref_SwitchSprite.set_sprite(pillar, Game_SpriteTypeTag.ACTIVE)


func _set_move_hit_point() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _ref_ObjectData.get_hit_point(pc) > 0:
		_ref_ObjectData.set_hit_point(pc, 0)


func _do_not_render_building(x: int, y: int) -> bool:
	var building: Sprite = _ref_DungeonBoard.get_building_xy(x, y)

	if (building != null) and building.is_in_group(Game_SubTag.COUNTER):
		return true
	return false


func _is_under_attack() -> bool:
	var x: int
	var y: int
	var npc: Sprite
	var horizontal_move: bool = (_source_position.y == _target_position.y)
	var vertical_move: bool = (_source_position.x == _target_position.x)
	var horizontal_attack := false
	var vertical_attack := false

	for i in RAY_DIRECTION:
		x = _source_position.x
		y = _source_position.y
		while true:
			x += i[0]
			y += i[1]
			if not Game_CrossShapedFOV.is_in_sight(x, y):
				break
			else:
				npc = _ref_DungeonBoard.get_sprite_xy(Game_MainTag.ACTOR, x, y)
				if npc == null:
					continue
				elif _ref_ObjectData.verify_state(npc, Game_StateTag.ACTIVE):
					if x == _source_position.x:
						vertical_attack = true
					elif y == _source_position.y:
						horizontal_attack = true
				break

	if (_ammo < 1) and horizontal_attack and vertical_attack:
		return false
	elif horizontal_move and horizontal_attack:
		if _ammo < 1:
			return _is_passable(VERTICAL)
		return true
	elif vertical_move and vertical_attack:
		if _ammo < 1:
			return _is_passable(HORIZONTAL)
		return true
	return false


func _is_passable(direction: int) -> bool:
	var x: int
	var y: int
	var shift_coord: Array

	match direction:
		HORIZONTAL:
			shift_coord = [RAY_DIRECTION[2], RAY_DIRECTION[3]]
		VERTICAL:
			shift_coord = [RAY_DIRECTION[0], RAY_DIRECTION[1]]
		_:
			return false

	for i in shift_coord:
		x = _source_position.x + i[0]
		y = _source_position.y + i[1]
		if (not Game_CoordCalculator.is_inside_dungeon(x, y)) \
				or _ref_DungeonBoard.has_building_xy(x, y) \
				or _ref_DungeonBoard.has_actor_xy(x, y):
			continue
		return true
	return false
