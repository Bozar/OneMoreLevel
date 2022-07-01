extends Game_PCActionTemplate


var _spr_Phantom := preload("res://sprite/Phantom.tscn")

var _pc_hit_target: bool


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_MirrorData.RENDER_RANGE


func render_fov() -> void:
	.render_fov()
	_reset_sprite_color()


func is_npc() -> bool:
	return _target_is_occupied(Game_MainTag.ACTOR)


func is_trap() -> bool:
	return _target_is_occupied(Game_MainTag.TRAP)


func move() -> void:
	_move_pc_and_image()
	end_turn = true


func attack() -> void:
	var mirror: Game_IntCoord
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _pc_hit_target:
		_create_image_on_the_other_side(_target_position.x, _target_position.y)
		_create_image_on_the_same_side(_target_position.x, _target_position.y)
		if _ref_ObjectData.get_hit_point(pc) == Game_MirrorData.MAX_CRYSTAL:
			_ref_EndGame.player_win()
		_ref_CountDown.add_count(Game_MirrorData.RESTORE_TURN)
	else:
		mirror = _get_mirror(_target_position.x, _target_position.y)
		_ref_RemoveObject.remove_actor_xy(mirror.x, mirror.y)
	end_turn = true


func interact_with_trap() -> void:
	var mirror: Game_IntCoord
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if not _pc_hit_target:
		mirror = _get_mirror(_target_position.x, _target_position.y)
		_ref_RemoveObject.remove_trap_xy(mirror.x, mirror.y)

	_move_pc_and_image()
	if _ref_ObjectData.get_hit_point(pc) == Game_MirrorData.MAX_CRYSTAL:
		_ref_EndGame.player_win()
	end_turn = true


func _is_checkmate() -> bool:
	var npc: Array = _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.PHANTOM)
	var trap: Sprite = _ref_DungeonBoard.get_sprites_by_tag(
			Game_SubTag.CRYSTAL)[0]
	var trap_x: int = Game_ConvertCoord.sprite_to_coord(trap).x

	for i in npc:
		if _ref_ObjectData.verify_state(i, Game_StateTag.DEFAULT):
			return false
	return (_source_position.x - Game_DungeonSize.CENTER_X) \
			* (trap_x - Game_DungeonSize.CENTER_X) > 0


func _get_mirror(x: int, y: int) -> Game_IntCoord:
	return Game_CoordCalculator.get_mirror_image_xy(x, y,
			Game_DungeonSize.CENTER_X, y)


func _target_is_occupied(main_tag: String) -> bool:
	var mirror := _get_mirror(_target_position.x, _target_position.y)

	if _ref_DungeonBoard.has_sprite_xy(main_tag,
			_target_position.x, _target_position.y):
		_pc_hit_target = true
		return true
	elif _ref_DungeonBoard.has_sprite_xy(main_tag, mirror.x, mirror.y):
		_pc_hit_target = false
		return true
	return false


func _create_image_on_the_other_side(x: int, y: int) -> void:
	var actor: Sprite = _ref_DungeonBoard.get_actor_xy(x, y)
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var mirror := _get_mirror(x, y)
	var images: Array
	var remove: int
	var pos: Game_IntCoord

	# On this side: Switch phantom's sprite into default.
	if _ref_DungeonBoard.has_trap_xy(x, y):
		_ref_SwitchSprite.set_sprite(actor, Game_SpriteTypeTag.DEFAULT)

	# On the other side: Remove an existing phantom.
	_ref_RemoveObject.remove_actor_xy(mirror.x, mirror.y)

	# Move the phantom to the other side. State: passive. Color: grey.
	_ref_DungeonBoard.move_actor_xy(x, y, mirror.x, mirror.y)
	_ref_ObjectData.set_state(actor, Game_StateTag.PASSIVE)

	# On the other side: Remove a trap.
	_ref_RemoveObject.remove_trap_xy(mirror.x, mirror.y)

	# There can be at most (5 - crystal) phantom images.
	images = _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.PHANTOM)
	Game_ArrayHelper.filter_element(images, self, "_filter_create_image",
			[actor])
	remove = images.size() + 1 - (Game_MirrorData.MAX_PHANTOM \
			- _ref_ObjectData.get_hit_point(pc))
	if remove > 0:
		Game_ArrayHelper.rand_picker(images, remove, _ref_RandomNumber)
		for i in images:
			pos = Game_ConvertCoord.sprite_to_coord(i)
			_ref_RemoveObject.remove_actor(pos)


func _create_image_on_the_same_side(x: int, y: int) -> void:
	var wall: Array = []
	var mirror: Game_IntCoord
	var actor: Sprite

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
		if _ref_DungeonBoard.has_building_xy(mirror.x, mirror.y):
			continue
		# Continue if there is an actor blocks the image.
		elif _ref_DungeonBoard.has_actor_xy(mirror.x, mirror.y):
			continue
		# Continue if the phantom and its image are on different sides.
		elif ((x - Game_DungeonSize.CENTER_X) \
				* (mirror.x - Game_DungeonSize.CENTER_X)) < 0:
			continue

		# Create a new actor.
		_ref_CreateObject.create_actor_xy(_spr_Phantom, Game_SubTag.PHANTOM,
				mirror.x, mirror.y)

		# Switch the actor's sprite to active.
		if _ref_DungeonBoard.has_trap_xy(mirror.x, mirror.y):
			actor = _ref_DungeonBoard.get_actor_xy(mirror.x, mirror.y)
			_ref_SwitchSprite.set_sprite(actor, Game_SpriteTypeTag.ACTIVE)


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

	_ref_DungeonBoard.move_actor_xy(_source_position.x, _source_position.y,
			_target_position.x, _target_position.y)
	_ref_DungeonBoard.move_actor_xy(source_mirror.x, source_mirror.y,
			target_mirror.x, target_mirror.y)
