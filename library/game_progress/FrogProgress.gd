extends Game_ProgressTemplate


var _spr_Frog := preload("res://sprite/Frog.tscn")
var _spr_FrogPrincess := preload("res://sprite/FrogPrincess.tscn")
var _spr_Counter := preload("res://sprite/Counter.tscn")

# wave counter:
# 0: 8 frogs | when 4 frogs disappear ->
# 1: princess, submerge land | when princess disappears ->
# 2: 8 frogs | when 4 frogs disappear ->
# 3: princess, 4 frogs, submerge land | when 4 frogs disappear ->
# -3: princess disappears before other frogs
# 4: princess
var _start_next_wave := true
var _wave_counter := 0
var _kill_counter := 0
var _counter_sprite: Sprite
var _ground_coords := []


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func end_world(pc_x: int, pc_y: int) -> void:
	var pc_pos: Game_IntCoord

	_init_ground_coords()

	if _start_next_wave:
		_start_next_wave = false
		_refresh_counter()
		pc_pos = Game_IntCoord.new(pc_x, pc_y)

		if _wave_counter == 0:
			_spawn_knights(pc_pos)
		elif _wave_counter == 1:
			_submerge_land(Game_FrogData.SUBMERGE_LAND)
			_remove_frog()
			_spawn_princess(pc_pos)
		elif _wave_counter == 2:
			_spawn_knights(pc_pos)
		elif _wave_counter == 3:
			_submerge_land(Game_FrogData.SUBMERGE_MORE_LAND)
			_spawn_princess(pc_pos)
		elif _wave_counter == -3:
			_spawn_princess(pc_pos)
			_wave_counter = 3


func remove_actor(actor: Sprite, _x: int, _y: int) -> void:
	var pc := _ref_DungeonBoard.get_pc()

	if actor.is_in_group(Game_SubTag.FROG):
		_kill_counter += 1
		if _kill_counter == Game_FrogData.HALF_FROG:
			_kill_counter = 0
			if (_wave_counter == 0) or (_wave_counter == 2) \
					or (_wave_counter == 3):
				_wave_counter += 1
				_start_next_wave = true
	elif actor.is_in_group(Game_SubTag.FROG_PRINCESS):
		if _wave_counter == 1:
			_wave_counter += 1
			_start_next_wave = true
		elif _wave_counter == 3:
			_wave_counter = -3
			_start_next_wave = true
		elif _wave_counter == 4:
			# Let FrogPCAction end game. Frog princess is not removed from
			# DungeonBoard at this moment. If we end game now, the ground under
			# princess is invisible.
			_ref_ObjectData.set_bool(pc, true)
			# _ref_EndGame.player_win()


func _spawn_frogs(pc_pos: Game_IntCoord, max_frogs: int,
		frog_sprite: PackedScene, sub_tag: String) -> void:
	var count_frogs := max_frogs
	var frog_coords := []

	while count_frogs > 0:
		count_frogs = _create_frog_in_loop(pc_pos, count_frogs, frog_sprite,
			sub_tag, frog_coords, count_frogs == max_frogs)


func _spawn_knights(pc_pos: Game_IntCoord) -> void:
	_spawn_frogs(pc_pos, Game_FrogData.MAX_FROG, _spr_Frog, Game_SubTag.FROG)


func _spawn_princess(pc_pos: Game_IntCoord) -> void:
	_spawn_frogs(pc_pos, Game_FrogData.MAX_PRINCESS, _spr_FrogPrincess,
			Game_SubTag.FROG_PRINCESS)


func _create_frog_in_loop(pc_pos: Game_IntCoord, count_frogs: int,
		frog_sprite: PackedScene, sub_tag: String, frog_coords: Array,
		is_first_loop: bool) -> int:
	Game_ArrayHelper.shuffle(_ground_coords, _ref_RandomNumber)
	for i in _ground_coords:
		if count_frogs < 1:
			break
		if _is_close_to_pc(i, pc_pos) or _is_far_from_pc(i, pc_pos):
			continue
		elif is_first_loop and _is_close_to_frogs(i, frog_coords):
			continue
		elif _ref_DungeonBoard.has_actor(i):
			continue
		count_frogs -= 1
		frog_coords.push_back(i)
		_ref_CreateObject.create_actor(frog_sprite, sub_tag, i)
	return count_frogs


func _submerge_land(submerge: int) -> void:
	var land_sprite := _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.LAND)
	var land_pos: Game_IntCoord

	Game_ArrayHelper.rand_picker(land_sprite, submerge, _ref_RandomNumber)
	for i in land_sprite:
		land_pos = Game_ConvertCoord.sprite_to_coord(i)
		_ref_RemoveObject.remove_ground(land_pos)
		_ref_CreateObject.create_ground(_spr_Floor, Game_SubTag.SWAMP, land_pos)


func _remove_frog() -> void:
	var frog := _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.FROG)
	var pos: Game_IntCoord

	for i in frog:
		pos = Game_ConvertCoord.sprite_to_coord(i)
		_ref_RemoveObject.remove_actor(pos)


func _refresh_counter() -> void:
	if _counter_sprite == null:
		_counter_sprite = _ref_DungeonBoard.get_sprites_by_tag(
				Game_SubTag.COUNTER)[0]
	if _wave_counter < 0:
		return
	_ref_SwitchSprite.set_sprite(_counter_sprite,
			Game_SpriteTypeTag.convert_digit_to_tag(_wave_counter + 1))


func _init_ground_coords() -> void:
	if _ground_coords.size() == 0:
		for x in range(0, Game_DungeonSize.MAX_X):
			for y in range(0, Game_DungeonSize.MAX_Y):
				_ground_coords.push_back(Game_IntCoord.new(x, y))


func _is_close_to_frogs(self_pos: Game_IntCoord, frog_coords: Array) -> bool:
	for i in frog_coords:
		if Game_CoordCalculator.is_in_range(self_pos, i,
				Game_FrogData.MIN_DISTANCE):
			return true
	return false


func _is_close_to_pc(self_pos: Game_IntCoord, pc_pos: Game_IntCoord) -> bool:
	return Game_CoordCalculator.is_in_range(self_pos, pc_pos,
			Game_FrogData.MID_DISTANCE)


func _is_far_from_pc(self_pos: Game_IntCoord, pc_pos: Game_IntCoord) -> bool:
	return Game_CoordCalculator.is_out_of_range(self_pos, pc_pos,
			Game_FrogData.MAX_DISTANCE)
