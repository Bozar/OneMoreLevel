extends Game_PCActionTemplate


const TRAJECTORY_MAIN_TAG := [Game_MainTag.TRAP, Game_MainTag.GROUND]
# id: [Game_IntCoord]
const ACTOR_TRAJECTORY := {}
const INPUT_TO_COORD := {
	Game_InputTag.MOVE_UP: Game_CoordCalculator.UP,
	Game_InputTag.MOVE_DOWN: Game_CoordCalculator.DOWN,
	Game_InputTag.MOVE_LEFT: Game_CoordCalculator.DOWN,
	Game_InputTag.MOVE_RIGHT: Game_CoordCalculator.DOWN,
}

const LEFT_WALL := 1
const RIGHT_WALL := 15
const WALL_LENGTH := 5
const WALL_COORD := [
	[LEFT_WALL, LEFT_WALL + WALL_LENGTH],
	[RIGHT_WALL, RIGHT_WALL + WALL_LENGTH],
]

var _spr_SoulFragment := preload("res://sprite/SoulFragment.tscn")

var _time_stop := 0
var _previous_pc_y := -1


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_NinjaData.PC_SIGHT


# A ninja is removed either because of being hit in NinjaPCAction (this script)
# or being idle in NinjaProgress.
func remove_data(remove_sprite: Sprite, main_tag: String, _x: int, _y: int) \
		-> void:
	if main_tag != Game_MainTag.ACTOR:
		return

	var id := remove_sprite.get_instance_id()
	var __

	_set_trajectory_type(id, Game_SpriteTypeTag.DEFAULT)
	__ = ACTOR_TRAJECTORY.erase(id)


func reset_state() -> void:
	# Initialize _previous_pc_y for the first time. Later, it will be set in
	# _update_indicator().
	if _previous_pc_y < 0:
		_previous_pc_y = _source_position.y
	_update_trajectory()
	_update_indicator()

	.reset_state()


func switch_sprite() -> void:
	var pc := _ref_DungeonBoard.get_pc()
	var new_tag := Game_SpriteTypeTag.convert_digit_to_tag(_time_stop) \
			if _time_stop > 0 \
			else Game_SpriteTypeTag.DEFAULT

	_ref_SwitchSprite.set_sprite(pc, new_tag)


func attack() -> void:
	_hit_actor(_target_position.x, _target_position.y)
	if _time_stop < 1:
		_time_stop = Game_NinjaData.MAX_TIME_STOP
		switch_sprite()

	_update_trajectory()
	_update_indicator()
	_try_end_game()


func wait() -> void:
	var __

	if _time_stop > 0:
		_time_stop = 0
		switch_sprite()
	elif _is_above_ground():
		__ = _charge_and_try_hit(Game_CoordCalculator.DOWN, false)
	end_turn = true


func interact_with_trap() -> void:
	_pc_move(true)


func move() -> void:
	_pc_move(false)


func _pc_move(has_trap: bool) -> void:
	if _time_stop > 0:
		_move_inside_time_stop(has_trap)
	else:
		_move_outside_time_stop()
	switch_sprite()

	_update_trajectory()
	_update_indicator()
	_try_end_game()


func _move_outside_time_stop() -> void:
	if _is_horizontal_move():
		_move_pc_sprite()
		if _charge_and_try_hit(Game_CoordCalculator.DOWN, true):
			_time_stop = Game_NinjaData.MAX_TIME_STOP
		else:
			end_turn = true
	elif _is_upward_move_from_ground() or _is_downward_move():
		if _charge_and_try_hit(INPUT_TO_COORD[_input_direction], true):
			_time_stop = Game_NinjaData.MAX_TIME_STOP
		else:
			end_turn = true


func _move_inside_time_stop(has_trap: bool) -> void:
	if _is_horizontal_move():
		_move_pc_sprite()
		if not has_trap:
			_time_stop -= 1
	elif not _charge_and_try_hit(INPUT_TO_COORD[_input_direction], true):
		if not has_trap:
			_time_stop -= 1
	end_turn = _time_stop < 1


# direction is Game_CoordCalculator.[UP|DOWN|LEFT|RIGHT]
func _charge_and_try_hit(direction: int, can_hit_npc: bool) -> bool:
	var pc_pos := _ref_DungeonBoard.get_pc_coord()
	var path := Game_CoordCalculator.get_ray_path(pc_pos.x, pc_pos.y,
			Game_NinjaData.PC_SPEED, direction, true, true, self,
			"_is_obstacle")
	var grid_pos: Game_IntCoord = path[path.size() - 1]
	var hit_npc := false

	if _ref_DungeonBoard.has_building_xy(grid_pos.x, grid_pos.y):
		grid_pos = path[path.size() - 2]
	elif _ref_DungeonBoard.has_actor_xy(grid_pos.x, grid_pos.y):
		if can_hit_npc:
			_hit_actor(grid_pos.x, grid_pos.y)
		grid_pos = path[path.size() - 2]
		hit_npc = can_hit_npc
	_ref_DungeonBoard.move_actor_xy(pc_pos.x, pc_pos.y, grid_pos.x, grid_pos.y)
	return hit_npc


func _is_above_ground() -> bool:
	return _source_position.y < Game_NinjaData.GROUND_Y


func _is_horizontal_move() -> bool:
	return _source_position.y == _target_position.y


func _is_downward_move() -> bool:
	return _target_position.y > _source_position.y


func _is_upward_move_from_ground() -> bool:
	return (_source_position.y == Game_NinjaData.GROUND_Y) \
			and (_target_position.y < _source_position.y)


func _update_trajectory() -> void:
	var actors := _ref_DungeonBoard.get_sprites_by_tag(Game_MainTag.ACTOR)
	var id: int
	var pos: Game_IntCoord
	var speed: int

	# Hide existing trajectories.
	for i in actors:
		id = i.get_instance_id()
		if ACTOR_TRAJECTORY.has(id):
			_set_trajectory_type(id, Game_SpriteTypeTag.DEFAULT)

	# Show new trajectories.
	for i in actors:
		id = i.get_instance_id()
		pos = Game_ConvertCoord.sprite_to_coord(i)
		if i.is_in_group(Game_SubTag.PC):
			speed = Game_NinjaData.PC_SPEED
		else:
			speed = Game_NinjaData.NINJA_SPEED
		ACTOR_TRAJECTORY[id] = Game_CoordCalculator.get_ray_path(pos.x, pos.y,
				speed, Game_CoordCalculator.DOWN, false, false, self,
				"_is_obstacle")
		_set_trajectory_type(id, Game_SpriteTypeTag.ACTIVE)


func _set_trajectory_type(id: int, sprite_type_tag: String) -> void:
	var this_sprite: Sprite

	for i in ACTOR_TRAJECTORY[id]:
		for j in TRAJECTORY_MAIN_TAG:
			this_sprite = _ref_DungeonBoard.get_sprite_xy(j, i.x, i.y)
			if this_sprite != null:
				_ref_SwitchSprite.set_sprite(this_sprite, sprite_type_tag)


func _is_obstacle(x: int, y: int, _opt_art: Array) -> bool:
	return _ref_DungeonBoard.has_actor_xy(x, y) \
			or _ref_DungeonBoard.has_building_xy(x, y)


func _hit_actor(x: int, y: int) -> void:
	var shadows := _ref_DungeonBoard.get_sprites_by_tag(
			Game_SubTag.NINJA_SHADOW)
	var shadow_pos: Game_IntCoord
	var create_trap := true

	for i in shadows:
		shadow_pos = Game_ConvertCoord.sprite_to_coord(i)
		if (x == shadow_pos.x) or (y == shadow_pos.y):
			create_trap = false
			break
	if create_trap:
		_ref_CreateObject.create_trap_xy(_spr_SoulFragment, Game_SubTag.TREASURE,
				x, y)
	else:
		_ref_RemoveObject.remove_trap_xy(x, y)
	_ref_RemoveObject.remove_actor_xy(x, y)


func _try_end_game() -> void:
	if _ref_DungeonBoard.get_npc().size() == 0:
		_ref_EndGame.player_win()
	else:
		render_fov()


func _update_indicator() -> void:
	var pos := _ref_DungeonBoard.get_pc_coord()
	var has_trap := _ref_DungeonBoard.has_trap_xy(pos.x, pos.y)
	var default_type := Game_SpriteTypeTag.DEFAULT
	var new_type := Game_SpriteTypeTag.ACTIVE \
			if has_trap \
			else Game_SpriteTypeTag.PASSIVE
	var wall: Sprite

	for i in WALL_COORD:
		for x in range(i[0], i[1]):
			# Reset the previous line.
			wall = _ref_DungeonBoard.get_building_xy(x, _previous_pc_y)
			_ref_SwitchSprite.set_sprite(wall, default_type)
			# Set the current line.
			wall = _ref_DungeonBoard.get_building_xy(x, pos.y)
			_ref_SwitchSprite.set_sprite(wall, new_type)
	_previous_pc_y = pos.y


func _post_process_fov(_pc_x: int, pc_y: int) -> void:
	var wall: Sprite

	for i in WALL_COORD:
		for x in range(i[0], i[1]):
			wall = _ref_DungeonBoard.get_building_xy(x, pc_y)
			_ref_Palette.set_default_color(wall, Game_MainTag.BUILDING)


func _render_end_game(win: bool) -> void:
	_update_trajectory()
	_update_indicator()

	._render_end_game(win)
