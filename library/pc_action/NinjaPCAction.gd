extends Game_PCActionTemplate


var _spr_Treasure := preload("res://sprite/Treasure.tscn")

var _is_time_stop: bool = false
var _count_time_stop: int = Game_NinjaData.MAX_TIME_STOP


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func switch_sprite() -> void:
	pass


func render_fov() -> void:
	if _ref_GameSetting.get_show_full_map():
		_render_without_fog_of_war()
		return

	_new_ShadowCastFOV.set_field_of_view(
			Game_DungeonSize.MAX_X, Game_DungeonSize.MAX_Y,
			_source_position[0], _source_position[1], Game_NinjaData.PC_SIGHT,
			self, "_block_line_of_sight", [])

	for x in range(Game_DungeonSize.MAX_X):
		for y in range(Game_DungeonSize.MAX_Y):
			for i in Game_MainGroupTag.DUNGEON_OBJECT:
				if (i == Game_MainGroupTag.BUILDING) \
						or (i == Game_MainGroupTag.GROUND):
					_set_sprite_color_with_memory(x, y, i, "", true,
							_new_ShadowCastFOV, "is_in_sight")
				else:
					_set_sprite_color(x, y, i, "",
							_new_ShadowCastFOV, "is_in_sight")


func interact_with_trap() -> void:
	_ref_RemoveObject.remove(Game_MainGroupTag.TRAP,
			_target_position[0], _target_position[1])
	move()


func attack() -> void:
	var push: Array = _new_CoordCalculator.get_mirror_image(
			_source_position[0], _source_position[1],
			_target_position[0], _target_position[1])
	var __

	if push.size() == 0:
		push = _target_position
	__ = _try_hit_npc(_target_position[0], _target_position[1],
			push[0], push[1], false)

	if not _is_time_stop:
		_switch_time_stop(true)
	render_fov()
	end_turn = false


func move() -> void:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			_target_position[0], _target_position[1], 1)
	var push_x: int
	var push_y: int
	var hit_npc: bool = false
	var pause_turn: bool

	_move_pc_sprite()

	for i in neighbor:
		if (i[0] == _source_position[0]) and (i[1] == _source_position[1]):
			continue
		elif i[0] == _source_position[0]:
			push_x = i[0]
			push_y = i[1] + (i[1] - _target_position[1])
		elif i[1] == _source_position[1]:
			push_x = i[0] + (i[0] - _target_position[0])
			push_y = i[1]
		elif i[0] == _target_position[0]:
			push_x = i[0] + (i[0] - _source_position[0])
			push_y = i[1]
		elif i[1] == _target_position[1]:
			push_x = i[0]
			push_y = i[1] + (i[1] - _source_position[1])

		if not _new_CoordCalculator.is_inside_dungeon(push_x, push_y):
			push_x = i[0]
			push_y = i[1]
		if _try_hit_npc(i[0], i[1], push_x, push_y, true):
			hit_npc = true

	if _is_time_stop:
		if not hit_npc:
			_count_time_stop -= 1
		pause_turn = _count_time_stop > 0
	else:
		pause_turn = hit_npc

	if pause_turn:
		_source_position[0] = _target_position[0]
		_source_position[1] = _target_position[1]
		render_fov()
	_switch_time_stop(pause_turn)
	end_turn = not _is_time_stop


func wait() -> void:
	if _is_time_stop:
		_switch_time_stop(false)
	.wait()


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_building(x, y) \
			or _ref_DungeonBoard.has_actor(x, y)


func _switch_time_stop(stop_time: bool) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if stop_time:
		_ref_SwitchSprite.switch_sprite(pc,
				_new_SpriteTypeTag.convert_digit_to_tag(_count_time_stop))
		_is_time_stop = true
	else:
		_count_time_stop = Game_NinjaData.MAX_TIME_STOP
		_ref_SwitchSprite.switch_sprite(pc, Game_SpriteTypeTag.DEFAULT)
		_is_time_stop = false


func _try_hit_npc(hit_x: int, hit_y: int, push_x: int, push_y: int,
		push_npc: bool) -> bool:
	var npc: Sprite = _ref_DungeonBoard.get_actor(hit_x, hit_y)
	var trap_x: int
	var trap_y: int
	var neighbor: Array
	var set_trap: bool

	if npc == null:
		return false
	elif npc.is_in_group(Game_SubGroupTag.BUTTERFLY_NINJA) \
			and _ref_ObjectData.verify_state(npc, Game_ObjectStateTag.DEFAULT):
		if not _ref_DungeonBoard.has_building(push_x, push_y):
			_ref_DungeonBoard.move_sprite(Game_MainGroupTag.ACTOR, hit_x, hit_y,
					push_x, push_y)
			_ref_RemoveObject.remove_trap(push_x, push_y)
		_ref_ObjectData.set_state(npc, Game_ObjectStateTag.PASSIVE)
		_ref_SwitchSprite.switch_sprite(npc, Game_SpriteTypeTag.PASSIVE)
		return true

	set_trap = not npc.is_in_group(Game_SubGroupTag.SHADOW_NINJA)
	_ref_RemoveObject.remove_actor(hit_x, hit_y)
	if not set_trap:
		return true

	if push_npc and (not _ref_DungeonBoard.has_building(push_x, push_y)):
		trap_x = push_x
		trap_y = push_y
	else:
		trap_x = hit_x
		trap_y = hit_y

	neighbor = _new_CoordCalculator.get_neighbor(trap_x, trap_y, 1, true)
	for i in neighbor:
		set_trap = true
		for j in Game_MainGroupTag.ABOVE_GROUND_OBJECT:
			if _ref_DungeonBoard.has_sprite(j, i[0], i[1]):
				set_trap = false
				break
		if set_trap:
			_ref_CreateObject.create(_spr_Treasure,
					Game_MainGroupTag.TRAP, Game_SubGroupTag.TREASURE,
					i[0], i[1])
	return true
