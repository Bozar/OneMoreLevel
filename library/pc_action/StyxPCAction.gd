extends Game_PCActionTemplate


const INVALID_DIRECTION := 0

const STATE_TO_INT := {
	Game_StateTag.UP: 1,
	Game_StateTag.DOWN: -1,
	Game_StateTag.LEFT: 2,
	Game_StateTag.RIGHT: -2,
	Game_StateTag.DEFAULT: INVALID_DIRECTION,
}
const INPUT_TO_INT := {
	Game_InputTag.MOVE_UP: 1,
	Game_InputTag.MOVE_DOWN: -1,
	Game_InputTag.MOVE_LEFT: 2,
	Game_InputTag.MOVE_RIGHT: -2,
}

var _explore_score := 0
var _sight_counter := Game_StyxData.NORMAL_THRESHOLD


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func render_fov() -> void:
	var pos: Game_IntCoord
	var distance: int
	var sight := _get_pc_sight()

	_set_render_sprites()
	if _ref_GameSetting.get_show_full_map():
		_render_without_fog_of_war()
		_switch_lighthouse_color()
		return

	for i in RENDER_SPRITES[Game_MainTag.GROUND]:
		i.visible = true
		pos = Game_ConvertCoord.vector_to_coord(i.position)
		distance = Game_CoordCalculator.get_range(pos.x, pos.y,
				_source_position.x, _source_position.y)
		if distance > sight:
			i.visible = false
		elif distance == sight:
			_ref_Palette.set_dark_color(i, Game_MainTag.GROUND)
		elif distance > 0:
			_ref_Palette.set_default_color(i, Game_MainTag.GROUND)
		else:
			i.visible = false
	_switch_lighthouse_color()


func wait() -> void:
	var pc := _ref_DungeonBoard.get_pc()

	_ref_ObjectData.set_state(pc, Game_StateTag.ACTIVE)
	_set_sight_counter(0)
	.wait()


func move() -> void:
	var x: int
	var y: int
	var source_direction: int = INPUT_TO_INT[_input_direction]
	var target_direction: int = _get_ground_direction(
			_target_position.x, _target_position.y)

	if _is_opposite_direction(source_direction, target_direction):
		end_turn = false
		return

	for i in Game_StateTag.DIRECTION_TO_COORD.keys():
		x = _target_position.x
		y = _target_position.y
		while Game_CoordCalculator.is_inside_dungeon(x, y) \
				and (_get_ground_direction(x, y) == STATE_TO_INT[i]):
			x += Game_StateTag.DIRECTION_TO_COORD[i][0]
			y += Game_StateTag.DIRECTION_TO_COORD[i][1]
		if (x != _target_position.x) or (y != _target_position.y):
			x -= Game_StateTag.DIRECTION_TO_COORD[i][0]
			y -= Game_StateTag.DIRECTION_TO_COORD[i][1]
			break
	_ref_DungeonBoard.move_sprite(Game_MainTag.ACTOR,
			_source_position.x, _source_position.y, x, y)
	_set_sight_counter(_sight_counter + 1)

	if _pc_is_near_harbor(x, y):
		_ref_EndGame.player_win()
		end_turn = false
	else:
		end_turn = true


func _is_opposite_direction(source: int, target: int) -> bool:
	if target == INVALID_DIRECTION:
		return false
	return source + target == 0


func _get_ground_direction(x: int, y: int) -> int:
	var ground := _ref_DungeonBoard.get_ground(x, y)

	if ground == null:
		return INVALID_DIRECTION
	return STATE_TO_INT[_ref_ObjectData.get_state(ground)]


func _switch_lighthouse_color() -> void:
	var lighthouse := _ref_DungeonBoard.get_building(Game_DungeonSize.CENTER_X,
			Game_DungeonSize.CENTER_Y)

	if _explore_score > Game_StyxData.MIN_SCORE:
		_ref_Palette.set_default_color(lighthouse, Game_MainTag.BUILDING)
	else:
		_ref_Palette.set_dark_color(lighthouse, Game_MainTag.BUILDING)


func _pc_is_near_harbor(x: int, y: int) -> bool:
	for i in Game_CoordCalculator.get_neighbor(x, y, 1):
		if _ref_DungeonBoard.has_sprite_with_sub_tag(Game_SubTag.HARBOR,
				i.x, i.y):
			return true
	return false


func _get_pc_sight() -> int:
	for i in Game_StyxData.THRESHOLD_TO_SIGHT:
		if _sight_counter < i:
			return Game_StyxData.THRESHOLD_TO_SIGHT[i]
	return Game_StyxData.MAX_SIGHT


func _set_sight_counter(counter: int) -> void:
	_sight_counter = counter

	if _sight_counter > Game_StyxData.MAX_THRESHOLD:
		_sight_counter = Game_StyxData.MAX_THRESHOLD
