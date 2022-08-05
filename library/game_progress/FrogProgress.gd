extends Game_ProgressTemplate


const MAX_RETRY := 5

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


func end_world(pc_coord: Game_IntCoord) -> void:
	_init_ground_coords()

	if _start_next_wave:
		_start_next_wave = false
		_refresh_counter()

		if _wave_counter == 0:
			_spawn_knights(pc_coord)
		elif _wave_counter == 1:
			_submerge_land(Game_FrogData.SUBMERGE_LAND)
			_remove_frog()
			_spawn_princess(pc_coord)
		elif _wave_counter == 2:
			_spawn_knights(pc_coord)
		elif _wave_counter == 3:
			_submerge_land(Game_FrogData.SUBMERGE_MORE_LAND)
			_spawn_princess(pc_coord)
		elif _wave_counter == -3:
			_spawn_princess(pc_coord)
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


func _spawn_knights(pc_pos: Game_IntCoord) -> void:
	Game_WorldGenerator.create_by_coord(_ground_coords,
			Game_FrogData.MAX_FROG, _ref_RandomNumber, self,
			"_is_valid_coord", [pc_pos],
			"_create_frog", [_spr_Frog, Game_SubTag.FROG])


func _spawn_princess(pc_pos: Game_IntCoord) -> void:
	Game_WorldGenerator.create_by_coord(_ground_coords,
			Game_FrogData.MAX_PRINCESS, _ref_RandomNumber, self,
			"_is_valid_coord", [pc_pos],
			"_create_frog", [_spr_FrogPrincess, Game_SubTag.FROG_PRINCESS])


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


func _is_close_to_frogs(self_pos: Game_IntCoord) -> bool:
	var npc_pos: Game_IntCoord

	for i in _ref_DungeonBoard.get_npc():
		npc_pos = Game_ConvertCoord.sprite_to_coord(i)
		if Game_CoordCalculator.is_in_range(self_pos, npc_pos,
				Game_FrogData.MIN_DISTANCE):
			return true
	return false


func _is_close_to_pc(self_pos: Game_IntCoord, pc_pos: Game_IntCoord) -> bool:
	return Game_CoordCalculator.is_in_range(self_pos, pc_pos,
			Game_FrogData.MID_DISTANCE)


func _is_far_from_pc(self_pos: Game_IntCoord, pc_pos: Game_IntCoord) -> bool:
	return Game_CoordCalculator.is_out_of_range(self_pos, pc_pos,
			Game_FrogData.MAX_DISTANCE)


func _create_frog(coord: Game_IntCoord, opt_arg: Array) -> void:
	var frog_sprite: PackedScene = opt_arg[0]
	var sub_tag: String = opt_arg[1]

	_ref_CreateObject.create_actor(frog_sprite, sub_tag, coord)


func _is_valid_coord(coord: Game_IntCoord, retry: int, opt_arg: Array) -> bool:
	var pc_pos: Game_IntCoord = opt_arg[0]

	if _is_close_to_pc(coord, pc_pos) or _is_far_from_pc(coord, pc_pos):
		return false
	elif (retry < MAX_RETRY) and _is_close_to_frogs(coord):
		return false
	elif _ref_DungeonBoard.has_actor(coord):
		return false
	return true
