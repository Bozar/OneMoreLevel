class_name Game_PCActionTemplate
# Scripts such as [DungeonType]PCAction.gd inherit this script.
# All functions except getters and setters can be overriden.
# The child should also implement _init() to pass arguments.


const RENDER_SPRITES := {
	Game_MainTag.GROUND: [],
	Game_MainTag.TRAP: [],
	Game_MainTag.BUILDING: [],
	Game_MainTag.ACTOR: [],
}

var message: String setget set_message, get_message
var end_turn: bool setget set_end_turn, get_end_turn

var _ref_DungeonBoard: Game_DungeonBoard
var _ref_RemoveObject: Game_RemoveObject
var _ref_ObjectData: Game_ObjectData
var _ref_RandomNumber: Game_RandomNumber
var _ref_EndGame: Game_EndGame
var _ref_CountDown: Game_CountDown
var _ref_SwitchSprite: Game_SwitchSprite
var _ref_CreateObject: Game_CreateObject
var _ref_DangerZone: Game_DangerZone
var _ref_GameSetting: Game_GameSetting
var _ref_Palette: Game_Palette

var _source_position: Game_IntCoord
var _target_position: Game_IntCoord
var _input_direction: String
# Set `_fov_render_range` if we use the default `_fov_render_range()`. Otherwise
# there is no need to set it.
var _fov_render_range := 5


# Refer: PlayerInput.gd.
func _init(parent_node: Node2D) -> void:
	_ref_DungeonBoard = parent_node._ref_DungeonBoard
	_ref_RemoveObject = parent_node._ref_RemoveObject
	_ref_ObjectData = parent_node._ref_ObjectData
	_ref_RandomNumber = parent_node._ref_RandomNumber
	_ref_EndGame = parent_node._ref_EndGame
	_ref_CountDown = parent_node._ref_CountDown
	_ref_SwitchSprite = parent_node._ref_SwitchSprite
	_ref_CreateObject = parent_node._ref_CreateObject
	_ref_DangerZone = parent_node._ref_DangerZone
	_ref_GameSetting = parent_node._ref_GameSetting
	_ref_Palette = parent_node._ref_Palette


func get_message() -> String:
	return message


func set_message(_message: String) -> void:
	pass


func allow_input() -> bool:
	if _is_checkmate():
		_ref_EndGame.player_lose()
		return false
	return true


func pass_turn() -> void:
	pass


func get_end_turn() -> bool:
	return end_turn


func set_end_turn(_end_turn: bool) -> void:
	pass


func is_inside_dungeon() -> bool:
	return Game_CoordCalculator.is_inside_dungeon(
			_target_position.x, _target_position.y)


func is_npc() -> bool:
	return _ref_DungeonBoard.has_actor_xy(
			_target_position.x, _target_position.y)


func is_building() -> bool:
	return _ref_DungeonBoard.has_building_xy(
			_target_position.x, _target_position.y)


func is_trap() -> bool:
	return _ref_DungeonBoard.has_trap_xy(_target_position.x, _target_position.y)

# 1. An action, (move or attack, for example) might call
# EndGame.player_[win|lose]() implicitly. Therefore we need to decide whether
# a thing happens before or after end game.
# 2. It is recommended to call CountDown.add_count() after EndGame.player_X.
# Therefore the counter in the sidebar panel does not update once game ends.
# This leads to a potential and satisfying situation in which players find that
# they beat the game in the last turn.
func move() -> void:
	_move_pc_sprite()
	end_turn = true


func attack() -> void:
	_ref_RemoveObject.remove_actor_xy(_target_position.x, _target_position.y)
	end_turn = true


func interact_with_building() -> void:
	pass


func interact_with_trap() -> void:
	pass


func wait() -> void:
	end_turn = true


func reset_state() -> void:
	end_turn = false


func set_source_position() -> void:
	_source_position = _ref_DungeonBoard.get_pc_coord()


func set_target_position(direction: String) -> void:
	var shift: Array = Game_InputTag.DIRECTION_TO_COORD[direction]

	_target_position = Game_IntCoord.new(
		_source_position.x + shift[0],
		_source_position.y + shift[1]
	)
	_input_direction = direction


func render_fov() -> void:
	var pc_pos := _ref_DungeonBoard.get_pc_coord()
	var this_pos: Game_IntCoord

	_set_render_sprites()
	if _ref_GameSetting.get_show_full_map():
		_render_without_fog_of_war()
		# _post_process_fov(pc_pos.x, pc_pos.y)
		return

	Game_ShadowCastFOV.set_field_of_view(
			Game_DungeonSize.MAX_X, Game_DungeonSize.MAX_Y,
			pc_pos.x, pc_pos.y, _fov_render_range,
			self, "_block_line_of_sight", [])

	for mtag in RENDER_SPRITES:
		for i in RENDER_SPRITES[mtag]:
			this_pos = Game_ConvertCoord.vector_to_coord(i.position)
			_set_sprite_color(this_pos.x, this_pos.y, mtag, Game_ShadowCastFOV,
					"is_in_sight")

	_post_process_fov(pc_pos.x, pc_pos.y)


func switch_sprite() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _ref_DangerZone.is_in_danger(_source_position.x, _source_position.y):
		_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.ACTIVE)
	else:
		_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.DEFAULT)


func game_over(win: bool) -> void:
	_render_end_game(win)
	switch_sprite()


func remove_data(_remove_sprite: Sprite, _main_tag: String, _x: int, _y: int) \
		-> void:
	pass


func _is_occupied(x: int, y: int) -> bool:
	if not Game_CoordCalculator.is_inside_dungeon(x, y):
		return true
	for i in Game_MainTag.ABOVE_GROUND_OBJECT:
		if _ref_DungeonBoard.has_sprite_xy(i, x, y):
			return true
	return false


func _is_checkmate() -> bool:
	return false


func _render_end_game(win: bool) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	render_fov()
	if not win:
		_ref_Palette.set_dark_color(pc, Game_MainTag.ACTOR)


func _render_without_fog_of_war() -> void:
	var pos: Game_IntCoord

	for mtag in RENDER_SPRITES:
		for i in RENDER_SPRITES[mtag]:
			pos = Game_ConvertCoord.vector_to_coord(i.position)
			i.visible = _sprite_is_visible(mtag, pos.x, pos.y, false)
			if mtag == Game_MainTag.GROUND:
				_ref_Palette.set_dark_color(i, mtag)


# is_in_sight_func(x: int, y: int) -> bool
func _set_sprite_color(x: int, y: int, main_tag: String, func_host: Object,
		is_in_sight_func: String, sprite_layer := 0) -> void:
	var set_this := _ref_DungeonBoard.get_sprite_xy(main_tag, x, y,
			sprite_layer)
	var is_in_sight := funcref(func_host, is_in_sight_func)

	if set_this == null:
		return
	set_this.visible = _sprite_is_visible(main_tag, x, y, false, sprite_layer)
	if is_in_sight.call_func(x, y):
		_ref_Palette.set_default_color(set_this, main_tag)
	else:
		_ref_Palette.set_dark_color(set_this, main_tag)


# is_in_sight_func(x: int, y: int) -> bool
func _set_sprite_color_with_memory(x: int, y: int, main_tag: String,
		ues_memory: bool, func_host: Object, is_in_sight_func: String,
		sprite_layer := 0) -> void:
	var set_this := _ref_DungeonBoard.get_sprite_xy(main_tag, x, y,
			sprite_layer)
	var is_in_sight := funcref(func_host, is_in_sight_func)

	if set_this == null:
		return
	set_this.visible = true
	if is_in_sight.call_func(x, y):
		set_this.visible = _sprite_is_visible(main_tag, x, y, false,
				sprite_layer)
		if ues_memory:
			_set_sprite_memory(x, y, main_tag, sprite_layer)
		_ref_Palette.set_default_color(set_this, main_tag)
	else:
		# Set visibility based on whether a sprite is covered.
		set_this.visible = _sprite_is_visible(main_tag, x, y, ues_memory,
				sprite_layer)
		if ues_memory and _has_sprite_memory(x, y, main_tag, sprite_layer):
			_ref_Palette.set_dark_color(set_this, main_tag)
		else:
			# Set visibility based on whether a sprite is remembered.
			set_this.visible = false


func _sprite_is_visible(main_tag: String, x: int, y: int, use_memory: bool,
		sprite_layer := 0) -> bool:
	var start_index: int = Game_ZIndex.get_z_index(main_tag) + 1
	var max_index: int = Game_ZIndex.LAYERED_MAIN_TAG.size()
	var current_tag: String

	# Check sprites from lower layer to higher ones.
	for i in range(start_index, max_index):
		current_tag = Game_ZIndex.LAYERED_MAIN_TAG[i]
		# There is a sprite on a certian layer.
		if _ref_DungeonBoard.has_sprite_xy(current_tag, x, y, sprite_layer):
			# Show or hide sprites based on memory and stacking layers.
			if use_memory:
				# There is a sprite on a higher layer and we remember it.
				if _has_sprite_memory(x, y, current_tag, sprite_layer):
					return false
				# There is a sprite on a higher layer but we do not remember it.
				# Therefore it is invisible for this rendering.
				continue
			# Show or hide sprites based on actual layers. Since there is a
			# sprite on a higher layer, our sprite in question is invisible.
			return false
	# Either there are no sprites on higher layers, or we do not remember any,
	# our sprite in question is visble.
	return true


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_building_xy(x, y) \
			or _ref_DungeonBoard.has_actor_xy(x, y)


func _has_sprite_memory(x: int, y: int, main_tag: String, sprite_layer := 0) \
		-> bool:
	var this_sprite := _ref_DungeonBoard.get_sprite_xy(main_tag, x, y,
			sprite_layer)
	return _ref_ObjectData.get_bool(this_sprite)


func _set_sprite_memory(x: int, y: int, main_tag: String, sprite_layer := 0) \
		-> void:
	var this_sprite := _ref_DungeonBoard.get_sprite_xy(main_tag, x, y,
			sprite_layer)
	_ref_ObjectData.set_bool(this_sprite, true)


func _move_pc_sprite() -> void:
	_ref_DungeonBoard.move_actor_xy(_source_position.x, _source_position.y,
			_target_position.x, _target_position.y)


# Render dungeon objects at the end of the default render_fov().
func _post_process_fov(_pc_x: int, _pc_y: int) -> void:
	pass


func _set_render_sprites() -> void:
	for i in RENDER_SPRITES:
		RENDER_SPRITES[i] = _ref_DungeonBoard.get_sprites_by_tag(i)
