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


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = _new_BalloonData.RENDER_RANGE


func switch_sprite() -> void:
	pass


func render_fov() -> void:
	if SHOW_FULL_MAP:
		_render_without_fog_of_war()
		return

	_new_ShadowCastFOV.set_field_of_view(
			_source_position[0], _source_position[1], _fov_render_range,
			self, "_block_line_of_sight", [])

	for x in range(_new_DungeonSize.MAX_X):
		for y in range(_new_DungeonSize.MAX_Y):
			for i in _new_MainGroupTag.DUNGEON_OBJECT:
				if i != _new_MainGroupTag.TRAP:
					_set_sprite_color(x, y, i, "",
							_new_ShadowCastFOV, "is_in_sight")


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
