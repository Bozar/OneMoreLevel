extends Game_AITemplate


#          true false
# hit_pc   10   0
# has_trap 1    0
const STATE_TO_SPRITE_TYPE := {
	11: Game_SpriteTypeTag.ACTIVE_1,
	10: Game_SpriteTypeTag.DEFAULT_1,
	1: Game_SpriteTypeTag.ACTIVE,
	0: Game_SpriteTypeTag.DEFAULT,
}
const HP_BAR := [
	[Game_DungeonSize.CENTER_X + 1, Game_NinjaData.MAX_X],
	[Game_NinjaData.MIN_X, Game_DungeonSize.CENTER_X],
]

var _end_game := false


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	# A newly created ninja waits one turn.
	if _ref_ObjectData.get_bool(_self):
		_ref_ObjectData.set_bool(_self, false)
		_switch_sprite(false)
		return

	if _self.is_in_group(Game_SubTag.NINJA):
		_ninja_act()
	else:
		_shadow_ninja_act()


func _ninja_act() -> void:
	var has_moved := false
	var hit_pc := false
	var move_result: Array
	var pc := _ref_DungeonBoard.get_pc()
	var pc_hp: int

	# Hit PC when inside attack range.
	if Game_CoordCalculator.is_inside_range_xy(_self_pos.x, _self_pos.y,
			_pc_pos.x, _pc_pos.y, Game_NinjaData.ATTACK_RANGE):
		hit_pc = true
	elif _self_pos.y == Game_NinjaData.GROUND_Y:
		# Try to jump and hit PC when standing on ground.
		move_result = _try_move_vertically(Game_CoordCalculator.UP)
		has_moved = move_result[0]
		hit_pc = move_result[1]
		# Otherwise try to move horizontally.
		if not has_moved:
			has_moved = _try_move_horizontally()
	else:
		# When in mid-air, move horizontally to PC when in close range.
		if abs(_self_pos.y - _pc_pos.y) < Game_NinjaData.VERTICAL_NINJA_SIGHT:
			has_moved = _try_move_horizontally()
		# Then fall down.
		move_result = _try_move_vertically(Game_CoordCalculator.DOWN)
		has_moved = has_moved or move_result[0]
		hit_pc = move_result[1]

	_switch_sprite(hit_pc)
	# Count how many turns a ninja has waited. Remove an idle ninja in
	# NinjaProgress.
	if has_moved or hit_pc:
		_ref_ObjectData.set_hit_point(_self, 0)
	else:
		_ref_ObjectData.add_hit_point(_self, 1)
	# Count how many hit PC has taken.
	if hit_pc:
		_ref_ObjectData.add_hit_point(pc, 1)
		pc_hp = _ref_ObjectData.get_hit_point(pc)
		_update_health_bar(pc_hp)
		if pc_hp >= Game_NinjaData.MAX_PC_HP:
			_ref_EndGame.player_lose()


func _shadow_ninja_act() -> void:
	var has_moved := false
	var move_result: Array

	_ref_RemoveObject.remove_trap(_self_pos.x, _self_pos.y)

	if _self_pos.y == Game_NinjaData.GROUND_Y:
		has_moved = _try_move_horizontally()
	else:
		move_result = _try_move_vertically(Game_CoordCalculator.DOWN)
		has_moved = move_result[0]

	_switch_sprite(false)
	if has_moved:
		_ref_ObjectData.set_hit_point(_self, 0)
	else:
		_ref_ObjectData.add_hit_point(_self, 1)


func _switch_sprite(hit_pc: bool) -> void:
	var pos := Game_ConvertCoord.vector_to_coord(_self.position)
	var has_trap := _ref_DungeonBoard.has_trap(pos.x, pos.y)
	var int_key := (hit_pc as int) * 10 + (has_trap as int)
	var new_sprite: String = STATE_TO_SPRITE_TYPE[int_key]

	_ref_SwitchSprite.set_sprite(_self, new_sprite)


# [has_moved, hit_pc]
func _try_move_vertically(direction: int) -> Array:
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

	if is_blocked:
		if path.size() > 1:
			last_grid = path[path.size() - 2]
		else:
			return [false, is_pc]
	else:
		last_grid = path[path.size() - 1]
	_ref_DungeonBoard.move_actor(pos.x, pos.y, last_grid.x, last_grid.y)
	return [true, is_pc]


func _try_move_horizontally() -> bool:
	var pos := Game_ConvertCoord.vector_to_coord(_self.position)
	var move_to: Game_IntCoord

	if pos.x < _pc_pos.x:
		move_to = Game_IntCoord.new(pos.x + 1, pos.y)
	elif pos.x > _pc_pos.x:
		move_to = Game_IntCoord.new(pos.x - 1, pos.y)
	else:
		return false

	if _ref_DungeonBoard.has_actor(move_to.x, move_to.y):
		return false
	_ref_DungeonBoard.move_actor(pos.x, pos.y, move_to.x, move_to.y)
	return true


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


func _update_health_bar(hit_point: int) -> void:
	var this_floor: Sprite
	var bar: Array

	if hit_point < 1:
		return

	bar = HP_BAR[hit_point - 1]
	for x in range(bar[0], bar[1]):
		this_floor = _ref_DungeonBoard.get_ground(x, Game_DungeonSize.MAX_Y - 1)
		_ref_SwitchSprite.set_sprite(this_floor, Game_SpriteTypeTag.PASSIVE)
