extends Game_PCActionTemplate


var _spr_Phantom := preload("res://sprite/Phantom.tscn")

var _pc_hit_target: bool


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_MirrorData.RENDER_RANGE


func render_fov() -> void:
	.render_fov()
	_reset_sprite_color()


func switch_sprite() -> void:
	var new_type: String
	var pos: Game_IntCoord

	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_MainTag.ACTOR):
		pos = Game_ConvertCoord.sprite_to_coord(i)
		if _ref_DungeonBoard.has_trap(pos):
			new_type = Game_SpriteTypeTag.ACTIVE
		else:
			new_type = Game_SpriteTypeTag.DEFAULT
		_ref_SwitchSprite.set_sprite(i, new_type)


func is_npc() -> bool:
	return _target_is_occupied(Game_MainTag.ACTOR)


func is_trap() -> bool:
	return _target_is_occupied(Game_MainTag.TRAP)


func move() -> void:
	_move_pc_and_image()
	end_turn = true


func attack() -> void:
	if _pc_hit_target:
		_hit_phantom()
	else:
		_push_image()


func interact_with_trap() -> void:
	_move_pc_and_image()
	end_turn = true


func _is_checkmate() -> bool:
	return _has_no_phantom() or (_is_out_of_sight() and _is_surrounded())


func _get_mirror(x: int, y: int) -> Game_IntCoord:
	return Game_CoordCalculator.get_mirror_image_xy(x, y,
			Game_DungeonSize.CENTER_X, y)


func _target_is_occupied(main_tag: String) -> bool:
	var mirror := _get_mirror(_target_position.x, _target_position.y)

	if _ref_DungeonBoard.has_sprite(main_tag, _target_position):
		_pc_hit_target = true
		return true
	elif _ref_DungeonBoard.has_sprite(main_tag, mirror):
		_pc_hit_target = false
		return true
	return false


func _create_image_on_the_other_side(x: int, y: int) -> void:
	var actor: Sprite = _ref_DungeonBoard.get_actor_xy(x, y)
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var mirror := _get_mirror(x, y)
	var images: Array
	var max_actors: int
	var pos: Game_IntCoord

	# On the other side: Remove an existing phantom.
	_ref_RemoveObject.remove_actor_xy(mirror.x, mirror.y)

	# Move the phantom to the other side. State: passive. Color: grey.
	_ref_DungeonBoard.move_actor_xy(x, y, mirror.x, mirror.y)
	_ref_ObjectData.set_state(actor, Game_StateTag.PASSIVE)

	# On the other side: Remove a trap.
	_ref_RemoveObject.remove_trap(mirror)

	# There can be at most (5 - crystal) phantom images.
	images = _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.PHANTOM)
	Game_ArrayHelper.filter_element(images, self, "_filter_create_image",
			[actor])
	max_actors = Game_MirrorData.MAX_PHANTOM - _ref_ObjectData.get_hit_point(pc)
	if max_actors < images.size():
		Game_ArrayHelper.shuffle(images, _ref_RandomNumber)
		for i in range(0, images.size()):
			if i < max_actors - 1:
				continue
			pos = Game_ConvertCoord.sprite_to_coord(images[i])
			_ref_RemoveObject.remove_actor(pos)


func _create_image_on_the_same_side(x: int, y: int) -> int:
	var wall: Array = []
	var mirror: Game_IntCoord
	var count_actors := 0

	# Cast a ray to the top.
	wall += _get_mirror_position(x, y, 0, -1, 0)
	# Cast a ray to the bottom.
	wall += _get_mirror_position(x, y, 0, 1, Game_DungeonSize.MAX_Y)
	# Cast a ray to the left.
	wall += _get_mirror_position(x, y, -1, 0, 0)
	# Cast a ray to the right.
	wall += _get_mirror_position(x, y, 1, 0, Game_DungeonSize.MAX_X)

	for i in wall:
		# Continue if the image is outside the dungeon.
		mirror = Game_CoordCalculator.get_mirror_image_xy(x, y, i[0], i[1])
		if not Game_CoordCalculator.is_inside_dungeon(mirror.x, mirror.y):
			continue

		# Continue if there is a building blocks the image.
		if _ref_DungeonBoard.has_building(mirror):
			continue
		# Continue if there is an actor blocks the image.
		elif _ref_DungeonBoard.has_actor(mirror):
			continue
		# Continue if the phantom and its image are on different sides.
		elif ((x - Game_DungeonSize.CENTER_X) \
				* (mirror.x - Game_DungeonSize.CENTER_X)) < 0:
			continue

		# Create a new actor.
		_ref_CreateObject.create_actor(_spr_Phantom, Game_SubTag.PHANTOM,
				mirror)
		count_actors += 1
	return count_actors


func _get_mirror_position(x: int, y: int, x_shift: int, y_shift: int,
		end_point: int) -> Array:
	var mirror: Array = []
	var cast_result: int

	# Cast a ray vertically.
	if x_shift == 0:
		for i in range(y, end_point, y_shift):
			cast_result = _cast_ray(x, i, x_shift, y_shift)
			if cast_result> 0:
				if cast_result == 2:
					mirror.push_back([x, i])
				break
	# Cast a ray horizontally.
	else:
		for i in range(x, end_point, x_shift):
			cast_result = _cast_ray(i, y, x_shift, y_shift)
			if cast_result > 0:
				if cast_result == 2:
					mirror.push_back([i, y])
				break
	return mirror


# 0: Continue. 1: Stop ray cast. 2: Stop ray cast and store current position.
func _cast_ray(x: int, y: int, x_shift: int, y_shift: int) -> int:
	# An actor blocks the ray.
	if _ref_DungeonBoard.has_actor_xy(x, y):
		return 1
	# A building blocks the ray.
	elif _ref_DungeonBoard.has_building_xy(x, y):
		# Create a refelection if the building (mirror) is facing the source.
		if _ref_DungeonBoard.has_building_xy(x + x_shift, y + y_shift):
			return 1
		return 2
	# The middle border stops the ray.
	elif x == Game_DungeonSize.CENTER_X:
		return 1
	# Keep casting the ray if nothing happens.
	return 0


func _filter_create_image(source: Array, index: int, opt_arg: Array) -> bool:
	var actor: Sprite = opt_arg[0]

	return (source[index] != actor) \
			and _ref_ObjectData.verify_state(source[index],
					Game_StateTag.PASSIVE)


func _reset_sprite_color() -> void:
	var set_this: Sprite
	var pos: Game_IntCoord

	for y in range(0, Game_DungeonSize.MAX_Y):
		set_this = _ref_DungeonBoard.get_building_xy(
				Game_DungeonSize.CENTER_X, y)
		_ref_Palette.set_default_color(set_this, Game_MainTag.BUILDING)

	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_MainTag.TRAP):
		pos = Game_ConvertCoord.sprite_to_coord(i)
		i.visible = not _ref_DungeonBoard.has_actor(pos)
		_ref_Palette.set_default_color(i, Game_MainTag.TRAP)


func _move_pc_and_image() -> void:
	var source_mirror := _get_mirror(_source_position.x, _source_position.y)
	var target_mirror := _get_mirror(_target_position.x, _target_position.y)

	_ref_DungeonBoard.move_actor(_source_position, _target_position)
	_ref_DungeonBoard.move_actor(source_mirror, target_mirror)


func _hit_phantom() -> void:
	# There is always a new actor on the other side.
	var new_actors := 1
	var pc := _ref_DungeonBoard.get_pc()

	_create_image_on_the_other_side(_target_position.x, _target_position.y)
	new_actors += _create_image_on_the_same_side(
			_target_position.x, _target_position.y)
	if new_actors > Game_MirrorData.MAX_ACTOR_FOR_RESTORE:
		new_actors = Game_MirrorData.MAX_ACTOR_FOR_RESTORE
	if _ref_ObjectData.get_hit_point(pc) == Game_MirrorData.MAX_CRYSTAL:
		# Call _ref_EndGame.player_win() in MirrorProgress.remove_trap().
		end_turn = false
	else:
		_ref_CountDown.add_count(Game_MirrorData.RESTORE_TURN * new_actors + 1)
		end_turn = true


func _push_image() -> void:
	var source_mirror := _get_mirror(_source_position.x, _source_position.y)
	var target_mirror := _get_mirror(_target_position.x, _target_position.y)
	var push_to := Game_CoordCalculator.get_mirror_image(source_mirror,
			target_mirror)

	if _is_valid_coord(push_to):
		_ref_DungeonBoard.move_actor(target_mirror, push_to)
		_ref_RemoveObject.remove_trap(push_to)
		_move_pc_and_image()
		end_turn = true
	else:
		end_turn = false


func _is_valid_coord(coord: Game_IntCoord) -> bool:
	if not Game_CoordCalculator.is_inside_dungeon(coord.x, coord.y):
		return false
	elif _ref_DungeonBoard.has_building(coord):
		return false
	elif _ref_DungeonBoard.has_actor(coord):
		return false
	return true


func _has_no_phantom() -> bool:
	var trap: Sprite = _ref_DungeonBoard.get_sprites_by_tag(
			Game_SubTag.CRYSTAL)[0]
	var trap_x: int = Game_ConvertCoord.sprite_to_coord(trap).x

	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.PHANTOM):
		if _ref_ObjectData.verify_state(i, Game_StateTag.DEFAULT):
			return false
	return (_source_position.x - Game_DungeonSize.CENTER_X) \
			* (trap_x - Game_DungeonSize.CENTER_X) > 0


func _is_out_of_sight() -> bool:
	var pos: Game_IntCoord

	for i in _ref_DungeonBoard.get_npc():
		pos = Game_ConvertCoord.sprite_to_coord(i)
		if Game_CoordCalculator.is_in_range(pos, _source_position,
				Game_MirrorData.PHANTOM_SIGHT) \
				and _ref_ObjectData.verify_state(i, Game_StateTag.DEFAULT):
			return false
	return true


func _is_surrounded() -> bool:
	var mirror_coord := Game_CoordCalculator.get_mirror_image(_source_position,
			Game_IntCoord.new(Game_DungeonSize.CENTER_X, _source_position.y))

	for i in Game_CoordCalculator.get_neighbor(mirror_coord, 1):
		if _ref_DungeonBoard.has_building(i):
			continue
		elif _ref_DungeonBoard.has_actor(i) and _image_is_blocked(i,
				mirror_coord):
			continue
		return false
	return true


func _image_is_blocked(phantom_image: Game_IntCoord, pc_image: Game_IntCoord) \
		-> bool:
	var push_to := Game_CoordCalculator.get_mirror_image(pc_image,
			phantom_image)

	if not Game_CoordCalculator.is_inside_dungeon(push_to.x, push_to.y):
		return true
	elif _ref_DungeonBoard.has_actor(push_to):
		return true
	elif _ref_DungeonBoard.has_building(push_to):
		return true
	return false
