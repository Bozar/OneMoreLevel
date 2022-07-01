extends Game_PCActionTemplate


const INVALID_DIRECTION := 0
const UNKNOWN_HP := 0
const SEEN_HP := 1
const REACHED_HP := 2

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
const RENDER_THIS := [Game_MainTag.GROUND, Game_MainTag.BUILDING]

var _reached_harbor := 0
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
		_set_lighthouse_color()
		return

	for mtags in RENDER_THIS:
		for i in RENDER_SPRITES[mtags]:
			i.visible = true
			pos = Game_ConvertCoord.vector_to_coord(i.position)
			distance = Game_CoordCalculator.get_range_xy(pos.x, pos.y,
					_source_position.x, _source_position.y)
			if distance > sight:
				i.visible = false
			elif distance == sight:
				_ref_Palette.set_dark_color(i, mtags)
			elif distance > 0:
				_ref_Palette.set_default_color(i, mtags)
			else:
				i.visible = false

			if mtags == Game_MainTag.BUILDING:
				if i.is_in_group(Game_SubTag.LIGHTHOUSE):
					i.visible = true
					_set_lighthouse_color()
				elif i.is_in_group(Game_SubTag.HARBOR):
					_set_harbor_visibility(i)
					_set_harbor_color(i)


func wait() -> void:
	var pc := _ref_DungeonBoard.get_pc()

	_ref_ObjectData.set_state(pc, Game_StateTag.ACTIVE)
	_set_sight_counter(0)
	_try_end_game()


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
	_ref_DungeonBoard.move_actor(_source_position.x, _source_position.y, x, y)

	_set_sight_counter(_sight_counter + 1)
	_try_discover_harbor(x, y)
	_try_end_game()


func _is_opposite_direction(source: int, target: int) -> bool:
	if target == INVALID_DIRECTION:
		return false
	return source + target == 0


func _get_ground_direction(x: int, y: int) -> int:
	var ground := _ref_DungeonBoard.get_ground(x, y)

	if ground == null:
		return INVALID_DIRECTION
	return STATE_TO_INT[_ref_ObjectData.get_state(ground)]


func _set_lighthouse_color() -> void:
	var lighthouse := _ref_DungeonBoard.get_building(Game_DungeonSize.CENTER_X,
			Game_DungeonSize.CENTER_Y)

	if _reached_harbor > Game_StyxData.MIN_REACHED_HARBOR:
		_ref_Palette.set_default_color(lighthouse, Game_MainTag.BUILDING)
	else:
		_ref_Palette.set_dark_color(lighthouse, Game_MainTag.BUILDING)


func _set_harbor_visibility(set_this: Sprite) -> void:
	if _ref_ObjectData.get_hit_point(set_this) > UNKNOWN_HP:
		set_this.visible = true


func _set_harbor_color(set_this: Sprite) -> void:
	if _ref_ObjectData.get_hit_point(set_this) > UNKNOWN_HP:
		_ref_Palette.set_default_color(set_this, Game_MainTag.BUILDING)


func _get_pc_sight() -> int:
	if _sight_counter < Game_StyxData.NORMAL_THRESHOLD:
		return Game_StyxData.MIN_SIGHT
	return Game_StyxData.NORMAL_SIGHT


func _try_discover_harbor(pc_x: int, pc_y: int) -> void:
	var harbor_pos: Game_IntCoord
	var pc_to_harbor: int
	var harbor_hp: int

	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.HARBOR):
		harbor_pos = Game_ConvertCoord.vector_to_coord(i.position)
		pc_to_harbor = Game_CoordCalculator.get_range_xy(pc_x, pc_y,
				harbor_pos.x, harbor_pos.y)
		harbor_hp = _ref_ObjectData.get_hit_point(i)

		if (pc_to_harbor == 1) and (harbor_hp < REACHED_HP):
			_ref_ObjectData.set_hit_point(i, REACHED_HP)
			_ref_SwitchSprite.set_sprite(i, Game_SpriteTypeTag.ACTIVE)
			_reached_harbor += 1
		elif (pc_to_harbor < _get_pc_sight()) and (harbor_hp < SEEN_HP):
			_ref_ObjectData.set_hit_point(i, SEEN_HP)


func _try_end_game() -> void:
	var max_reach := _reached_harbor == Game_StyxData.MAX_HARBOR
	var last_turn := (_ref_CountDown.get_count(true) == 1) \
			and (_reached_harbor > Game_StyxData.MIN_REACHED_HARBOR)

	if max_reach or last_turn:
		_ref_EndGame.player_win()
		end_turn = false
	else:
		end_turn = true


func _set_sight_counter(counter: int) -> void:
	var lighthouse := _ref_DungeonBoard.get_building(
			Game_DungeonSize.CENTER_X, Game_DungeonSize.CENTER_Y)
	var delta_counter: int
	var new_type: String

	_sight_counter = min(counter, Game_StyxData.NORMAL_THRESHOLD) as int

	delta_counter = Game_StyxData.NORMAL_THRESHOLD - _sight_counter
	new_type = Game_SpriteTypeTag.convert_digit_to_tag(delta_counter)
	_ref_SwitchSprite.set_sprite(lighthouse, new_type)
