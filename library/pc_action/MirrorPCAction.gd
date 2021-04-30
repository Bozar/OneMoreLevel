extends Game_PCActionTemplate


var _spr_Phantom := preload("res://sprite/Phantom.tscn")

var _pc_hit_target: bool


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_MirrorData.RENDER_RANGE


func render_fov() -> void:
	.render_fov()
	_reset_sprite_color()


func is_npc() -> bool:
	return _target_is_occupied(Game_MainGroupTag.ACTOR)


func is_trap() -> bool:
	return _target_is_occupied(Game_MainGroupTag.TRAP)


func move() -> void:
	_move_pc_and_image()
	end_turn = true


func attack() -> void:
	var mirror: Array
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _pc_hit_target:
		_create_image_on_the_other_side(
				_target_position[0], _target_position[1])
		_create_image_on_the_same_side(
				_target_position[0], _target_position[1])
		if _ref_ObjectData.get_hit_point(pc) == Game_MirrorData.MAX_CRYSTAL:
			_ref_EndGame.player_win()
		_ref_CountDown.add_count(Game_MirrorData.RESTORE_TURN)
	else:
		mirror = _get_mirror(_target_position[0], _target_position[1])
		_ref_RemoveObject.remove_actor(mirror[0], mirror[1])
	end_turn = true


func interact_with_trap() -> void:
	var mirror: Array
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if not _pc_hit_target:
		mirror = _get_mirror(_target_position[0], _target_position[1])
		_ref_RemoveObject.remove_trap(mirror[0], mirror[1])

	_move_pc_and_image()
	if _ref_ObjectData.get_hit_point(pc) == Game_MirrorData.MAX_CRYSTAL:
		_ref_EndGame.player_win()
	end_turn = true


func _is_checkmate() -> bool:
	var npc: Array = _ref_DungeonBoard.get_sprites_by_tag(
			Game_SubGroupTag.PHANTOM)
	var trap: Sprite = _ref_DungeonBoard.get_sprites_by_tag(
			Game_SubGroupTag.CRYSTAL)[0]
	var trap_x: int = _new_ConvertCoord.vector_to_array(trap.position)[0]

	for i in npc:
		if _ref_ObjectData.verify_state(i, Game_ObjectStateTag.DEFAULT):
			return false
	return (_source_position[0] - Game_DungeonSize.CENTER_X) \
			* (trap_x - Game_DungeonSize.CENTER_X) > 0


func _get_mirror(x: int, y: int) -> Array:
	return _new_CoordCalculator.get_mirror_image(x, y,
			Game_DungeonSize.CENTER_X, y)


func _target_is_occupied(main_group_tag: String) -> bool:
	var mirror: Array = _get_mirror(_target_position[0], _target_position[1])

	if _ref_DungeonBoard.has_sprite(main_group_tag,
			_target_position[0], _target_position[1]):
		_pc_hit_target = true
		return true
	elif _ref_DungeonBoard.has_sprite(main_group_tag,
			mirror[0], mirror[1]):
		_pc_hit_target = false
		return true
	return false


func _create_image_on_the_other_side(x: int, y: int) -> void:
	var actor: Sprite = _ref_DungeonBoard.get_actor(x, y)
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var mirror: Array = _get_mirror(x, y)
	var images: Array
	var remove: int
	var position: Array

	# On this side: Switch phantom's sprite into default.
	if _ref_DungeonBoard.has_trap(x, y):
		_ref_SwitchSprite.switch_sprite(actor, Game_SpriteTypeTag.DEFAULT)

	# On the other side: Remove an existing phantom.
	_ref_RemoveObject.remove_actor(mirror[0], mirror[1])

	# Move the phantom to the other side. State: passive. Color: grey.
	_ref_DungeonBoard.move_sprite(Game_MainGroupTag.ACTOR,
			x, y, mirror[0], mirror[1])
	_ref_ObjectData.set_state(actor, Game_ObjectStateTag.PASSIVE)

	# On the other side: Remove a trap.
	_ref_RemoveObject.remove_trap(mirror[0], mirror[1])

	# There can be at most (5 - crystal) phantom images.
	images = _ref_DungeonBoard.get_sprites_by_tag(Game_SubGroupTag.PHANTOM)
	_new_ArrayHelper.filter_element(images, self, "_filter_create_image",
			[actor])
	remove = images.size() + 1 - (Game_MirrorData.MAX_PHANTOM \
			- _ref_ObjectData.get_hit_point(pc))
	if remove > 0:
		_new_ArrayHelper.rand_picker(images, remove, _ref_RandomNumber)
		for i in images:
			position = _new_ConvertCoord.vector_to_array(i.position)
			_ref_RemoveObject.remove_actor(position[0], position[1])


func _create_image_on_the_same_side(x: int, y: int) -> void:
	var wall: Array = []
	var mirror: Array
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
		mirror = _new_CoordCalculator.get_mirror_image(x, y, i[0], i[1])
		if mirror.size() == 0:
			continue

		# Continue if there is a building blocks the image.
		if _ref_DungeonBoard.has_building(mirror[0], mirror[1]):
			continue
		# Continue if there is an actor blocks the image.
		elif _ref_DungeonBoard.has_actor(mirror[0], mirror[1]):
			continue
		# Continue if the phantom and its image are on different sides.
		elif ((x - Game_DungeonSize.CENTER_X) \
				* (mirror[0] - Game_DungeonSize.CENTER_X)) < 0:
			continue

		# Create a new actor.
		_ref_CreateObject.create(
				_spr_Phantom,
				Game_MainGroupTag.ACTOR, Game_SubGroupTag.PHANTOM,
				mirror[0], mirror[1])

		# Switch the actor's sprite to active.
		if _ref_DungeonBoard.has_trap(mirror[0], mirror[1]):
			actor = _ref_DungeonBoard.get_actor(mirror[0], mirror[1])
			_ref_SwitchSprite.switch_sprite(actor, Game_SpriteTypeTag.ACTIVE)


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
	if _ref_DungeonBoard.has_actor(x, y):
		return 1
	# A building blocks the ray.
	elif _ref_DungeonBoard.has_building(x, y):
		# Create a refelection if the building (mirror) is facing the source.
		if _ref_DungeonBoard.has_building(x + x_shift, y + y_shift):
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
					Game_ObjectStateTag.PASSIVE)


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_building(x, y) \
			or _ref_DungeonBoard.has_actor(x, y)


func _reset_sprite_color() -> void:
	var set_this: Sprite
	var pos: Array

	for y in range(0, Game_DungeonSize.MAX_Y):
		set_this = _ref_DungeonBoard.get_building(Game_DungeonSize.CENTER_X, y)
		_ref_Palette.set_default_color(set_this, Game_MainGroupTag.BUILDING)

	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_MainGroupTag.TRAP):
		pos = _new_ConvertCoord.vector_to_array(i.position)
		i.visible = not _ref_DungeonBoard.has_actor(pos[0], pos[1])
		_ref_Palette.set_default_color(i, Game_MainGroupTag.TRAP)


func _move_pc_and_image() -> void:
	var source_mirror: Array = _get_mirror(
			_source_position[0], _source_position[1])
	var target_mirror: Array = _get_mirror(
			_target_position[0], _target_position[1])

	_ref_DungeonBoard.move_sprite(Game_MainGroupTag.ACTOR,
			_source_position[0], _source_position[1],
			_target_position[0], _target_position[1])
	_ref_DungeonBoard.move_sprite(Game_MainGroupTag.ACTOR,
			source_mirror[0], source_mirror[1],
			target_mirror[0], target_mirror[1])
