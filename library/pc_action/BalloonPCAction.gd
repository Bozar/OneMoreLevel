extends "res://library/pc_action/PCActionTemplate.gd"


const TELEPORT_X: Dictionary = {
	-1: DUNGEON_SIZE.MAX_X - 1,
	DUNGEON_SIZE.MAX_X: 0,
}
const TELEPORT_Y: Dictionary = {
	-1: DUNGEON_SIZE.MAX_Y - 1,
	DUNGEON_SIZE.MAX_Y: 0,
}

var _new_BalloonData := preload("res://library/npc_data/BalloonData.gd").new()

var _wall_sprite: Array
var _beacon_sprite: Array


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func switch_sprite() -> void:
	pass


func render_fov() -> void:
	if SHOW_FULL_MAP:
		return

	if _wall_sprite.size() == 0:
		_wall_sprite = _ref_DungeonBoard.get_sprites_by_tag(
				_new_MainGroupTag.BUILDING)
	if _beacon_sprite.size() == 0:
		_beacon_sprite = _ref_DungeonBoard.get_sprites_by_tag(
			_new_MainGroupTag.TRAP)

	for i in _wall_sprite:
		_set_color(i, _new_MainGroupTag.BUILDING)
	for i in _beacon_sprite:
		_set_color(i, _new_MainGroupTag.TRAP)


func wait() -> void:
	_wind_blow()
	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.TRAP,
			_source_position[0], _source_position[1]):
		_reach_destination(_source_position[0], _source_position[1])
	end_turn = true


func interact_with_building() -> void:
	_bounce_off(_source_position[0], _source_position[1],
			_target_position[0], _target_position[1])
	end_turn = true


func interact_with_trap() -> void:
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position[0], _source_position[1],
			_target_position[0], _target_position[1])
	_reach_destination(_target_position[0], _target_position[1])
	end_turn = true


func set_target_position(direction: String) -> void:
	_wind_blow()
	.set_target_position(direction)
	_target_position = _try_move_over_border(_target_position)


func _wind_blow() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.ACTOR,
			_source_position[0], _source_position[1])
	var wind_direction: Array = _new_ObjectStateTag.DIRECTION_TO_COORD[ \
			_ref_ObjectData.get_state(pc)]
	var new_position: Array = [
		_source_position[0] + wind_direction[0],
		_source_position[1] + wind_direction[1]
	]

	new_position = _try_move_over_border(new_position)
	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING,
			new_position[0], new_position[1]):
		_bounce_off(_source_position[0], _source_position[1],
				new_position[0], new_position[1])
	else:
		_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
				_source_position[0], _source_position[1],
				new_position[0], new_position[1])
	_source_position = _new_ConvertCoord.vector_to_array(pc.position)


func _try_move_over_border(position: Array) -> Array:
	var x: int = position[0]
	var y: int = position[1]

	if TELEPORT_X.has(x):
		x = TELEPORT_X[x]
	if TELEPORT_Y.has(y):
		y = TELEPORT_Y[y]
	return [x, y]


func _reach_destination(x: int, y: int) -> void:
	_new_ArrayHelper.filter_element(_beacon_sprite, self, "_beacon_not_lighted",
			[x, y])
	_ref_RemoveObject.remove(_new_MainGroupTag.TRAP, x, y)
	_ref_CountDown.add_count(_new_BalloonData.RESTORE_TURN)


func _bounce_off(pc_x: int, pc_y: int, wall_x: int, wall_y: int) -> void:
	var wall: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.BUILDING,
			wall_x, wall_y)
	var new_position: Array = _new_CoordCalculator.get_mirror_image(
			wall_x, wall_y, pc_x, pc_y, true)
	new_position = _try_move_over_border(new_position)

	if _ref_ObjectData.verify_state(wall, _new_ObjectStateTag.DEFAULT):
		_ref_ObjectData.set_state(wall, _new_ObjectStateTag.ACTIVE)
		_ref_SwitchSprite.switch_sprite(wall, _new_SpriteTypeTag.ACTIVE)
		_ref_CountDown.add_count(_new_BalloonData.MINOR_RESTORE_TURN)

	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING,
			new_position[0], new_position[1]):
		return
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR, pc_x, pc_y,
			new_position[0], new_position[1])


func _set_color(set_sprite: Sprite, main_tag: String) -> void:
	var pos: Array = _new_ConvertCoord.vector_to_array(set_sprite.position)

	if _new_CoordCalculator.is_inside_range(pos[0], pos[1],
			_source_position[0], _source_position[1],
			_new_BalloonData.RENDER_RANGE):
		_new_Palette.reset_color(set_sprite, main_tag)
	else:
		set_sprite.modulate = _new_Palette.DARK


func _beacon_not_lighted(source: Array, index: int, opt_arg: Array) -> bool:
	var x: int = opt_arg[0]
	var y: int = opt_arg[1]
	var pos: Array = _new_ConvertCoord.vector_to_array(source[index].position)

	return (pos[0] != x) or (pos[1] != y)
