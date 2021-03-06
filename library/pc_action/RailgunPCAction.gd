extends "res://library/pc_action/PCActionTemplate.gd"


const HALF_SIGHT_WIDTH: int = 1
const MEMORY_MARKER: int = 1

var _spr_Treasure := preload("res://sprite/Treasure.tscn")
var _spr_Portal := preload("res://sprite/Portal.tscn")

var _new_RailgunData := preload("res://library/npc_data/RailgunData.gd").new()
var _new_LinearFOV := preload("res://library/LinearFOV.gd").new()

var _floor_wall_sprite: Array
var _counter_sprite: Array = []
var _kill_count: int = _new_RailgunData.MAX_KILL_COUNT
var _ammo: int = _new_RailgunData.MAX_AMMO
var _face_direction: Array = [0, -1]
var _pillar_sprite: Sprite
var _has_found_pillar: bool = false
var _plillar_position: Array


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func set_target_position(direction: String) -> void:
	_face_direction = DIRECTION_TO_COORD[direction]
	.set_target_position(direction)


# Switch PC sprite when: PC waits, PC shoots or game ends.
func switch_sprite() -> void:
	pass


func game_over(_win) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	.game_over(_win)
	_hide_ground_under_pc()
	_switch_mode(true, pc)


func render_fov() -> void:
	# A wall sprite will be replaced by pillar sprite in _init_skull_pillar().
	_init_skull_pillar()
	_init_floor_wall()
	_init_counter()
	_render_counter(_kill_count)

	if SHOW_FULL_MAP:
		return

	_new_LinearFOV.set_rectangular_sight(
			_source_position[0], _source_position[1],
			_face_direction[0], _face_direction[1],
			_new_RailgunData.PC_FRONT_SIGHT, _new_RailgunData.PC_SIDE_SIGHT,
			HALF_SIGHT_WIDTH,
			self, "_block_ray", [])

	for i in _floor_wall_sprite:
		_set_color(i, _new_Palette.SHADOW, _new_Palette.DARK, true)
	for i in _ref_DungeonBoard.get_sprites_by_tag(_new_SubGroupTag.DEVIL):
		_set_color(i, _new_Palette.get_default_color(_new_MainGroupTag.ACTOR),
				"", false)
	if _has_found_pillar:
		_new_Palette.reset_color(_pillar_sprite, _new_MainGroupTag.BUILDING)


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
			and (not _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING,
					x, y)):
		if not _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, x, y):
			x += _face_direction[0]
			y += _face_direction[1]
			continue

		_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR, x, y)
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
	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR,
			_target_position[0], _target_position[1]):
		return
	_pc_move()


func interact_with_trap() -> void:
	_ref_RemoveObject.remove(_new_MainGroupTag.TRAP,
			_target_position[0], _target_position[1])
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
		if not (_ref_DungeonBoard.has_sprite(
				_new_MainGroupTag.BUILDING, i[0], i[1]) \
						or _ref_DungeonBoard.has_sprite(
								_new_MainGroupTag.ACTOR, i[0], i[1])):
			return false
	return true


func _block_ray(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y)


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
			if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.GROUND,
					j[0], j[1]):
				_ref_RemoveObject.remove(_new_MainGroupTag.BUILDING,
						pos[0], pos[1])
				_pillar_sprite = _ref_CreateObject.create_and_fetch(
						_spr_Portal,
						_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
						pos[0], pos[1])
				_plillar_position = pos
				return


func _init_counter() -> void:
	if _counter_sprite.size() == 0:
		for x in range(_new_DungeonSize.MAX_X - _new_RailgunData.COUNTER_WIDTH,
				_new_DungeonSize.MAX_X):
			_counter_sprite.push_back(_ref_DungeonBoard.get_sprite(
					_new_MainGroupTag.BUILDING,
					x, _new_DungeonSize.MAX_Y - 1))
			_counter_sprite.back().modulate = _new_Palette.DARK


func _init_floor_wall() -> void:
	var tmp_sprite: Array

	if SHOW_FULL_MAP:
		return

	if _floor_wall_sprite.size() == 0:
		_floor_wall_sprite = _ref_DungeonBoard.get_sprites_by_tag(
				_new_MainGroupTag.GROUND)
		tmp_sprite = _ref_DungeonBoard.get_sprites_by_tag(
				_new_SubGroupTag.WALL)
		_new_ArrayHelper.merge(_floor_wall_sprite, tmp_sprite)


func _set_color(set_this: Sprite, in_sight: String, out_of_sight: String,
		has_memory: bool) -> void:
	var pos: Array = _new_ConvertCoord.vector_to_array(set_this.position)

	set_this.visible = true
	if _new_LinearFOV.is_in_sight(pos[0], pos[1]):
		set_this.modulate = in_sight
		if has_memory and (_ref_ObjectData.get_hit_point(set_this) \
				< MEMORY_MARKER):
			_ref_ObjectData.set_hit_point(set_this, MEMORY_MARKER)
	elif has_memory and (_ref_ObjectData.get_hit_point(set_this) \
			== MEMORY_MARKER):
		set_this.modulate = out_of_sight
	else:
		set_this.visible = false


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
	if _has_found_pillar:
		return
	_has_found_pillar = _new_CoordCalculator.is_inside_range(
			_target_position[0], _target_position[1],
			_plillar_position[0], _plillar_position[1],
			_new_RailgunData.TOUCH_PILLAR)
	if _has_found_pillar:
		_ref_SwitchSprite.switch_sprite(_pillar_sprite,
				_new_SpriteTypeTag.ACTIVE)


func _set_move_hit_point() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _ref_ObjectData.get_hit_point(pc) > 0:
		_ref_ObjectData.set_hit_point(pc, 0)
