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
var _start_next_wave: bool = true
var _wave_counter: int = 0
var _kill_counter: int = 0
var _counter_sprite: Sprite


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func end_world(pc_x: int, pc_y: int) -> void:
	if _start_next_wave:
		_start_next_wave = false
		_refresh_counter()

		if _wave_counter == 1:
			_submerge_land(Game_FrogData.SUBMERGE_LAND)
			_remove_frog()
			_create_princess(pc_x, pc_y)
		elif _wave_counter == 2:
			_create_frog(pc_x, pc_y)
		elif _wave_counter == 3:
			_submerge_land(Game_FrogData.SUBMERGE_MORE_LAND)
			_create_princess(pc_x, pc_y)
		elif _wave_counter == -3:
			_create_princess(pc_x, pc_y)
			_wave_counter = 3


func remove_actor(actor: Sprite, _x: int, _y: int) -> void:
	var pc: Sprite

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
			pc = _ref_DungeonBoard.get_pc()
			_ref_ObjectData.set_hit_point(pc, 1)
			# _ref_EndGame.player_win()


func _create_frog(pc_x: int, pc_y: int) -> void:
	var neighbor := Game_CoordCalculator.get_neighbor_xy(pc_x, pc_y,
			Game_FrogData.MAX_DISTANCE)

	Game_ArrayHelper.filter_element(neighbor, self, "_filter_create_frog",
			[pc_x, pc_y])
	Game_ArrayHelper.rand_picker(neighbor, Game_FrogData.MAX_FROG,
			_ref_RandomNumber)

	for i in neighbor:
		_ref_CreateObject.create_actor_xy(_spr_Frog, Game_SubTag.FROG, i.x, i.y)


func _create_princess(pc_x: int, pc_y: int) -> void:
	var neighbor := Game_CoordCalculator.get_neighbor_xy(pc_x, pc_y,
			Game_FrogData.MAX_PRINCESS_DISTANCE)

	Game_ArrayHelper.filter_element(neighbor, self, "_filter_create_frog",
			[pc_x, pc_y])
	Game_ArrayHelper.duplicate_element(neighbor, self, "_dup_create_princess",
			[])
	Game_ArrayHelper.rand_picker(neighbor, 1, _ref_RandomNumber)

	_ref_CreateObject.create_actor_xy(_spr_FrogPrincess,
			Game_SubTag.FROG_PRINCESS, neighbor[0].x, neighbor[0].y)


func _submerge_land(submerge: int) -> void:
	var land_sprite: Array = _ref_DungeonBoard.get_sprites_by_tag(
			Game_SubTag.LAND)
	var land_pos: Game_IntCoord
	var x: int
	var y: int

	Game_ArrayHelper.rand_picker(land_sprite, submerge, _ref_RandomNumber)
	for i in land_sprite:
		land_pos = Game_ConvertCoord.vector_to_coord(i.position)
		x = land_pos.x
		y = land_pos.y
		_ref_RemoveObject.remove_ground_xy(x, y)
		_ref_CreateObject.create_ground_xy(_spr_Floor, Game_SubTag.SWAMP, x, y)


func _remove_frog() -> void:
	var frog: Array = _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.FROG)
	var pos: Game_IntCoord

	for i in frog:
		pos = Game_ConvertCoord.vector_to_coord(i.position)
		_ref_RemoveObject.remove_actor_xy(pos.x, pos.y)


func _refresh_counter() -> void:
	if _counter_sprite == null:
		_counter_sprite = _ref_DungeonBoard.get_sprites_by_tag(
				Game_SubTag.COUNTER)[0]
	if _wave_counter < 0:
		return
	_ref_SwitchSprite.set_sprite(_counter_sprite,
			Game_SpriteTypeTag.convert_digit_to_tag(_wave_counter + 1))


func _filter_create_frog(source: Array, index: int, opt_arg: Array) -> bool:
	var x: int = source[index].x
	var y: int = source[index].y
	var pc_x: int = opt_arg[0]
	var pc_y: int = opt_arg[1]

	if Game_CoordCalculator.is_inside_range_xy(x, y, pc_x, pc_y,
			Game_FrogData.MIN_DISTANCE) \
					or _ref_DungeonBoard.has_actor_xy(x, y):
		return false
	return true


func _dup_create_princess(source: Array, index: int, _opt_arg: Array) -> int:
	var x: int = source[index].x
	var y: int = source[index].y

	if _ref_DungeonBoard.has_sprite_with_sub_tag_xy(Game_SubTag.SWAMP, x, y):
		return 2
	return 1
