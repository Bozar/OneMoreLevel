extends "res://library/pc_action/PCActionTemplate.gd"


const HALF_SIGHT_WIDTH: int = 1
const MEMORY_MARKER: int = 1

var _spr_Treasure := preload("res://sprite/Treasure.tscn")
var _spr_Portal := preload("res://sprite/Portal.tscn")

var _new_RailgunData := preload("res://library/npc_data/RailgunData.gd").new()

var _counter_sprite: Array = []
var _kill_count: int = _new_RailgunData.MAX_KILL_COUNT
var _ammo: int = _new_RailgunData.MAX_AMMO
var _face_direction: Array = [0, -1]
var _has_found_pillar: bool = false
var _plillar_position: Array


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func set_target_position(direction: String) -> void:
	_face_direction = _new_InputTag.DIRECTION_TO_COORD[direction]
	.set_target_position(direction)


# Switch PC sprite when: PC waits, PC shoots or game ends.
func switch_sprite() -> void:
	pass


func game_over(win) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	_render_end_game(win)
	_switch_mode(true, pc)


func render_fov() -> void:
	# A wall sprite will be replaced by pillar sprite in _init_skull_pillar().
	_init_skull_pillar()
	_init_counter()
	_render_counter(_kill_count)

	if _ref_GameSetting.get_show_full_map():
		_render_without_fog_of_war()
		return

	_new_CrossShapedFOV.set_t_shaped_sight(
			_source_position[0], _source_position[1],
			_face_direction[0], _face_direction[1],
			HALF_SIGHT_WIDTH,
			_new_RailgunData.PC_FRONT_SIGHT, _new_RailgunData.PC_SIDE_SIGHT,
			self, "_block_line_of_sight", [])

	for x in range(_new_DungeonSize.MAX_X):
		for y in range(_new_DungeonSize.MAX_Y):
			for i in _new_MainGroupTag.DUNGEON_OBJECT:
				match i:
					_new_MainGroupTag.ACTOR:
						_set_sprite_color_with_memory(x, y, i, "", false,
								_new_CrossShapedFOV, "is_in_sight")
					_new_MainGroupTag.TRAP:
						_set_sprite_color(x, y, i, "",
								_new_CrossShapedFOV, "is_in_sight")
					_:
						if _do_not_render_building(x, y):
							pass
						else:
							_set_sprite_color_with_memory(x, y, i, "", true,
									_new_CrossShapedFOV, "is_in_sight")


func is_inside_dungeon() -> bool:
	return true


func is_npc() -> bool:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	return _is_aim_mode(pc)


func is_building() -> bool:
	return (not .is_inside_dungeon()) or .is_building()


func wait() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	_switch_mode(not _is_aim_mode(pc), pc)


func attack() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var x: int = _target_position[0]
	var y: int = _target_position[1]

	if _ammo < 1:
		return
	_ammo -= 1
	_ammo = max(_ammo, 0) as int
	_ref_ObjectData.add_hit_point(pc, _new_RailgunData.GUN_SHOT_HP)
	_switch_mode(false, pc)

	while _new_CoordCalculator.is_inside_dungeon(x, y) \
			and (not _ref_DungeonBoard.has_building(x, y)):
		if not _ref_DungeonBoard.has_actor(x, y):
			x += _face_direction[0]
			y += _face_direction[1]
			continue

		_ref_RemoveObject.remove_actor(x, y)
		_ref_CreateObject.create(_spr_Treasure,
				_new_MainGroupTag.TRAP, _new_SubGroupTag.TREASURE, x, y)

		_kill_count -= _new_RailgunData.ONE_KILL
		if _ammo == 0:
			_kill_count -= _new_RailgunData.ONE_KILL
		if _new_CoordCalculator.is_inside_range(
				_source_position[0], _source_position[1],
				x, y, _new_RailgunData.CLOSE_RANGE):
			_kill_count -= _new_RailgunData.ONE_KILL
		_kill_count = max(_kill_count, 0) as int
		break

	if _kill_count == 0:
		_ref_EndGame.player_win()
	else:
		end_turn = true


func move() -> void:
	if _ref_DungeonBoard.has_actor(_target_position[0], _target_position[1]):
		return
	_pc_move()


func interact_with_trap() -> void:
	_ref_RemoveObject.remove_trap(_target_position[0], _target_position[1])
	_pc_restore()
	_pc_move()


func _pc_move() -> void:
	_set_move_hit_point()
	_try_find_pillar()
	.move()


func _pc_restore() -> void:
	_ref_CountDown.add_count(_new_RailgunData.RESTORE_TURN)
	_ammo += _new_RailgunData.RESTORE_AMMO
	_ammo = min(_ammo, _new_RailgunData.MAX_AMMO) as int


func _is_checkmate() -> bool:
	var neighbor: Array

	if _ammo > 0:
		return false

	neighbor = _new_CoordCalculator.get_neighbor(
			_source_position[0], _source_position[1], 1)
	for i in neighbor:
		if not (_ref_DungeonBoard.has_building(i[0], i[1]) \
						or _ref_DungeonBoard.has_actor(i[0], i[1])):
			return false
	return true


func _block_ray(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_building(x, y)


func _init_skull_pillar() -> void:
	var building: Array
	var pos: Array
	var neighbor: Array

	if _plillar_position.size() > 0:
		return

	building = _ref_DungeonBoard.get_sprites_by_tag(_new_SubGroupTag.WALL)
	_new_ArrayHelper.rand_picker(building, building.size(), _ref_RandomNumber)

	for i in building:
		pos = _new_ConvertCoord.vector_to_array(i.position)
		if _new_CoordCalculator.is_inside_range(pos[0], pos[1],
				_source_position[0], _source_position[1],
				_new_DungeonSize.CENTER_X):
			continue

		neighbor = _new_CoordCalculator.get_neighbor(pos[0], pos[1], 1, false)
		for j in neighbor:
			if _ref_DungeonBoard.has_ground(j[0], j[1]):
				_ref_RemoveObject.remove_building(pos[0], pos[1])
				_ref_CreateObject.create(_spr_Portal,
						_new_MainGroupTag.BUILDING, _new_SubGroupTag.PILLAR,
						pos[0], pos[1])
				_plillar_position = pos
				return


func _init_counter() -> void:
	if _counter_sprite.size() == 0:
		for x in range(_new_DungeonSize.MAX_X - _new_RailgunData.COUNTER_WIDTH,
				_new_DungeonSize.MAX_X):
			_counter_sprite.push_back(_ref_DungeonBoard.get_building(
					x, _new_DungeonSize.MAX_Y - 1))
			_ref_Palette.set_dark_color(_counter_sprite.back(),
					_new_MainGroupTag.BUILDING)


func _render_counter(kill: int) -> void:
	var counter: Array = []
	var sprite_type: String

	for _i in range(_new_RailgunData.COUNTER_WIDTH):
		if kill > _new_RailgunData.COUNTER_DIGIT:
			counter.push_front(_new_RailgunData.COUNTER_DIGIT)
		else:
			counter.push_front(kill)
		kill -= _new_RailgunData.COUNTER_DIGIT
		kill = max(kill, 0) as int

	for i in range(counter.size()):
		sprite_type = _new_SpriteTypeTag.convert_digit_to_tag(counter[i])
		_ref_SwitchSprite.switch_sprite(_counter_sprite[i], sprite_type)


func _switch_mode(aim_mode: bool, pc: Sprite) -> void:
	var new_state: String
	var new_sprite: String

	if aim_mode:
		new_state = _new_ObjectStateTag.ACTIVE
		new_sprite = _new_SpriteTypeTag.convert_digit_to_tag(_ammo)
	else:
		new_state = _new_ObjectStateTag.DEFAULT
		new_sprite = _new_SpriteTypeTag.DEFAULT

	_ref_ObjectData.set_state(pc, new_state)
	_ref_SwitchSprite.switch_sprite(pc, new_sprite)


func _is_aim_mode(pc: Sprite) -> bool:
	return _ref_ObjectData.verify_state(pc, _new_ObjectStateTag.ACTIVE)


func _try_find_pillar() -> void:
	var pillar: Sprite

	if _has_found_pillar:
		return
	_has_found_pillar = _new_CoordCalculator.is_inside_range(
			_target_position[0], _target_position[1],
			_plillar_position[0], _plillar_position[1],
			_new_RailgunData.TOUCH_PILLAR)
	if _has_found_pillar:
		pillar = _ref_DungeonBoard.get_building(
				_plillar_position[0], _plillar_position[1])
		_ref_SwitchSprite.switch_sprite(pillar, _new_SpriteTypeTag.ACTIVE)


func _set_move_hit_point() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _ref_ObjectData.get_hit_point(pc) > 0:
		_ref_ObjectData.set_hit_point(pc, 0)


func _get_sprite_memory(x: int, y: int, main_tag: String, _sub_tag: String) \
		-> bool:
	var this_sprite: Sprite = _ref_DungeonBoard.get_sprite(main_tag, x, y)
	return _ref_ObjectData.get_hit_point(this_sprite) == MEMORY_MARKER


func _set_sprite_memory(x: int, y: int, main_tag: String, _sub_tag: String) \
		-> void:
	var this_sprite: Sprite = _ref_DungeonBoard.get_sprite(main_tag, x, y)
	_ref_ObjectData.set_hit_point(this_sprite, MEMORY_MARKER)


func _do_not_render_building(x: int, y: int) -> bool:
	var building: Sprite = _ref_DungeonBoard.get_building(x, y)

	if building == null:
		return false
	if building.is_in_group(_new_SubGroupTag.PILLAR):
		return _has_found_pillar
	elif building.is_in_group(_new_SubGroupTag.COUNTER):
		return true
	return false
