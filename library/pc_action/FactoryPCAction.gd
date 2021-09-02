extends Game_PCActionTemplate


const CLOCK_TYPE := [
	Game_SpriteTypeTag.DOWN,
	Game_SpriteTypeTag.LEFT,
	Game_SpriteTypeTag.UP,
	Game_SpriteTypeTag.RIGHT
]

var _is_first_render := true
var _find_clock: Sprite
var _find_npcs := []
var _treasure := 0
var _rare_treasure := 0


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func reset_state() -> void:
	_ref_ObjectData.set_state(_ref_DungeonBoard.get_pc(), Game_StateTag.DEFAULT)
	.reset_state()


func switch_sprite() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var new_type: String = Game_SpriteTypeTag.convert_digit_to_tag(_treasure)

	_ref_SwitchSprite.switch_sprite(pc, new_type)


func render_fov() -> void:
	var show_full_map: bool = _ref_GameSetting.get_show_full_map()
	var pos: Array

	if _is_first_render:
		_init_sprites()
		_is_first_render = false

	if show_full_map:
		_render_without_fog_of_war()

	Game_ShadowCastFOV.set_field_of_view(
			Game_DungeonSize.MAX_X, Game_DungeonSize.MAX_Y,
			_source_position[0], _source_position[1], _fov_render_range,
			self, "_block_line_of_sight", [])

	for i in _find_npcs:
		pos = Game_ConvertCoord.vector_to_array(i.position)
		if Game_ShadowCastFOV.is_in_sight(pos[0], pos[1]):
			_ref_ObjectData.set_state(i, Game_StateTag.ACTIVE)

	if show_full_map:
		return

	for x in range(Game_DungeonSize.MAX_X):
		for y in range(Game_DungeonSize.MAX_Y):
			for i in Game_MainTag.DUNGEON_OBJECT:
				_set_sprite_color_with_memory(x, y, i, i != Game_MainTag.ACTOR,
						Game_ShadowCastFOV, "is_in_sight")
	_ref_Palette.set_default_color(_find_clock, Game_MainTag.BUILDING)


func interact_with_building() -> void:
	if _ref_DungeonBoard.has_sprite_with_sub_tag(Game_SubTag.DOOR,
			_target_position[0], _target_position[1]):
		move()


func interact_with_trap() -> void:
	var trap: Sprite = _ref_DungeonBoard.get_sprite(Game_MainTag.TRAP,
			_target_position[0], _target_position[1])
	var win: bool
	var __

	if trap.is_in_group(Game_SubTag.RARE_TREASURE):
		_rare_treasure += 1
		_ref_SwitchSprite.switch_sprite(_find_clock, CLOCK_TYPE[_rare_treasure])
		win = _rare_treasure == Game_FactoryData.MAX_RARE_TREASURE
		if not win:
			_ref_CountDown.add_count(Game_FactoryData.RESTORE_RARE_TREASURE)
	elif trap.is_in_group(Game_SubTag.TREASURE):
		if _is_dying():
			end_turn = false
			return
		_treasure += 1
		_treasure = min(_treasure, Game_FactoryData.MAX_TREASURE_SLOT) as int

	_ref_RemoveObject.remove_trap(_target_position[0], _target_position[1])
	._move_pc_sprite()

	if win:
		_ref_EndGame.player_win()
		end_turn = false
	else:
		end_turn = true


func wait() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _treasure > 0:
		_treasure -= 1
		_ref_CountDown.add_count(Game_FactoryData.RESTORE_TREASURE)
	if _is_cornered():
		_ref_ObjectData.set_state(pc, Game_StateTag.PASSIVE)
	.wait()


func move() -> void:
	if _is_dying():
		end_turn = false
	else:
		.move()


func attack() -> void:
	end_turn = false


func _init_sprites() -> void:
	_find_clock = _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.ARROW)[0]
	_find_npcs = _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.SCP_173)


func _show_or_hide_sprite(sprites: Array, auto_reset: bool) -> void:
	var pos: Array

	for i in sprites:
		pos = Game_ConvertCoord.vector_to_array(i.position)
		if _ref_DungeonBoard.has_actor(pos[0], pos[1]):
			if auto_reset or Game_ShadowCastFOV.is_in_sight(pos[0], pos[1]):
				i.visible = false
		elif auto_reset:
			i.visible = true


func _is_dying() -> bool:
	return (_ref_CountDown.get_count(false) < 2) and (_treasure > 0)


func _is_cornered() -> bool:
	var building: Sprite

	for i in Game_CoordCalculator.get_neighbor(
			_source_position[0], _source_position[1], 1):
		if _ref_DungeonBoard.has_actor(i[0], i[1]):
			continue
		else:
			building = _ref_DungeonBoard.get_building(i[0], i[1])
			if (building == null) or building.is_in_group(Game_SubTag.DOOR):
				return false
			continue
		return false
	return true
