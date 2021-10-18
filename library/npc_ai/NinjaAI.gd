extends Game_AITemplate


#          true false
# end_game 10   0
# has_trap 1    0
const STATE_TO_SPRITE_TYPE := {
	11: Game_SpriteTypeTag.ACTIVE_1,
	10: Game_SpriteTypeTag.DEFAULT_1,
	1: Game_SpriteTypeTag.ACTIVE,
	0: Game_SpriteTypeTag.DEFAULT,
}

var _end_game := false


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	var has_trap: bool
	var pc: Sprite
	var __

	if _end_game:
		return

	pc = _ref_DungeonBoard.get_pc()
	if Game_CoordCalculator.is_inside_range(_self_pos.x, _self_pos.y,
			_pc_pos.x, _pc_pos.y, Game_NinjaData.ATTACK_RANGE):
		_end_game = true
	elif _self_pos.y == Game_NinjaData.GROUND_Y:
		if not _try_move_vertically(Game_CoordCalculator.UP):
			_try_move_horizontally()
	else:
		_try_move_horizontally()
		__ = _try_move_vertically(Game_CoordCalculator.DOWN)

	_self_pos = Game_ConvertCoord.vector_to_coord(_self.position)
	has_trap = _ref_DungeonBoard.has_trap(_self_pos.x, _self_pos.y)
	_switch_sprite(_end_game, has_trap)
	if _end_game:
		_ref_ObjectData.set_bool(pc, true)


func _switch_sprite(end_game: bool, has_trap: bool) -> void:
	var int_key := (end_game as int) * 10 + (has_trap as int)
	var new_sprite: String = STATE_TO_SPRITE_TYPE[int_key]

	_ref_SwitchSprite.set_sprite(_self, new_sprite)


func _try_move_vertically(direction: int) -> bool:
	var pos := Game_ConvertCoord.vector_to_coord(_self.position)
	var path: Array
	var is_blocked := false
	var is_pc := false
	var check_last_grid := [is_blocked, is_pc]
	var last_grid: Game_IntCoord

	path = Game_CoordCalculator.get_ray_path(pos.x, pos.y,
			Game_NinjaData.NINJA_SPEED, direction, false, true, self,
			"_ray_is_blocked", check_last_grid)
	is_blocked = check_last_grid[0]
	is_pc = check_last_grid[1]
	_end_game = is_pc

	if is_blocked:
		if path.size() > 1:
			last_grid = path[path.size() - 2]
		else:
			return false
	else:
		last_grid = path[path.size() - 1]
	_ref_DungeonBoard.move_sprite(Game_MainTag.ACTOR, pos.x, pos.y,
			last_grid.x, last_grid.y)
	return true


func _try_move_horizontally() -> void:
	var pos := Game_ConvertCoord.vector_to_coord(_self.position)
	var move_to: Game_IntCoord

	if pos.x < _pc_pos.x:
		move_to = Game_IntCoord.new(pos.x + 1, pos.y)
	elif pos.x > _pc_pos.x:
		move_to = Game_IntCoord.new(pos.x - 1, pos.y)
	else:
		move_to = pos
	if not _ref_DungeonBoard.has_actor(move_to.x, move_to.y):
		_ref_DungeonBoard.move_sprite(Game_MainTag.ACTOR, pos.x, pos.y,
				move_to.x, move_to.y)


# opt_arg = [last_grid_is_blocked, last_grid_is_pc]
func _ray_is_blocked(x: int, y: int, opt_arg: Array) -> bool:
	opt_arg[0] = true
	if not Game_CoordCalculator.is_inside_dungeon(x, y):
		return true
	elif _ref_DungeonBoard.has_building(x, y):
		return true
	elif _ref_DungeonBoard.has_actor(x, y):
		if (x == _pc_pos.x) and (y == _pc_pos.y):
			opt_arg[1] = true
		return true
	opt_arg[0] = false
	return false
