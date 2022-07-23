extends Game_PCActionTemplate


const CLOCK_TYPE := [
	Game_SpriteTypeTag.DOWN,
	Game_SpriteTypeTag.LEFT,
	Game_SpriteTypeTag.UP,
	Game_SpriteTypeTag.RIGHT
]

var _find_clock: Sprite
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

	_ref_SwitchSprite.set_sprite(pc, new_type)


func render_fov() -> void:
	var show_full_map := _ref_GameSetting.get_show_full_map()
	var pos: Game_IntCoord

	_set_render_sprites()
	if _find_clock == null:
		_find_clock = _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.ARROW)[0]

	Game_ShadowCastFOV.set_field_of_view(
			Game_DungeonSize.MAX_X, Game_DungeonSize.MAX_Y,
			_source_position.x, _source_position.y, Game_FactoryData.PC_SIGHT,
			self, "_block_line_of_sight", [])

	# Refer to FactoryAI.gd.
	for i in _ref_DungeonBoard.get_npc():
		pos = Game_ConvertCoord.sprite_to_coord(i)
		if Game_ShadowCastFOV.is_in_sight(pos.x, pos.y):
			_ref_ObjectData.set_state(i, Game_StateTag.ACTIVE)

	if show_full_map:
		_render_without_fog_of_war()
		return

	for mtag in RENDER_SPRITES:
		for i in RENDER_SPRITES[mtag]:
			pos = Game_ConvertCoord.sprite_to_coord(i)
			_set_sprite_color_with_memory(pos.x, pos.y, mtag,
					mtag != Game_MainTag.ACTOR, Game_ShadowCastFOV,
					"is_in_sight")

	_ref_Palette.set_default_color(_find_clock, Game_MainTag.BUILDING)


func interact_with_building() -> void:
	if _ref_DungeonBoard.has_sprite_with_sub_tag(Game_MainTag.BUILDING,
			Game_SubTag.DOOR, _target_position):
		move()


func interact_with_trap() -> void:
	var trap := _ref_DungeonBoard.get_trap(_target_position)
	var win: bool
	var __

	if trap.is_in_group(Game_SubTag.RARE_TREASURE):
		_rare_treasure += 1
		_ref_SwitchSprite.set_sprite(_find_clock, CLOCK_TYPE[_rare_treasure])
		win = _rare_treasure == Game_FactoryData.MAX_RARE_TREASURE
		if not win:
			_ref_CountDown.add_count(Game_FactoryData.RESTORE_RARE_TREASURE)
	# PC may die from picking up a fake rare gadget. This is not a bug.
	elif trap.is_in_group(Game_SubTag.TREASURE):
		if _is_dying():
			end_turn = false
			return
		_treasure += 1
		_treasure = int(min(_treasure, Game_FactoryData.MAX_TREASURE_SLOT))

	_ref_RemoveObject.remove_trap(_target_position)
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


func _show_or_hide_sprite(sprites: Array, auto_reset: bool) -> void:
	var pos: Game_IntCoord

	for i in sprites:
		pos = Game_ConvertCoord.sprite_to_coord(i)
		if _ref_DungeonBoard.has_actor(pos):
			if auto_reset or Game_ShadowCastFOV.is_in_sight(pos.x, pos.y):
				i.visible = false
		elif auto_reset:
			i.visible = true


func _is_dying() -> bool:
	return (_ref_CountDown.get_count(false) < 2) and (_treasure > 0)


func _is_cornered() -> bool:
	var building: Sprite

	for i in Game_CoordCalculator.get_neighbor(_source_position, 1):
		if _ref_DungeonBoard.has_actor(i):
			continue
		else:
			building = _ref_DungeonBoard.get_building(i)
			if (building == null) or building.is_in_group(Game_SubTag.DOOR):
				return false
			continue
		return false
	return true
