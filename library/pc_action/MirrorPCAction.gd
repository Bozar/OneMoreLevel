extends "res://library/pc_action/PCActionTemplate.gd"


var _spr_Phantom := preload("res://sprite/Phantom.tscn")

var _new_MirrorData := preload("res://library/npc_data/MirrorData.gd").new()

var _pc_hit_target: bool


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func is_npc() -> bool:
	return _target_is_occupied(_new_MainGroupTag.ACTOR)


func is_trap() -> bool:
	return _target_is_occupied(_new_MainGroupTag.TRAP)


func move() -> void:
	var source_mirror: Array = _get_mirror(
			_source_position[0], _source_position[1])
	var target_mirror: Array = _get_mirror(
			_target_position[0], _target_position[1])
	var crystal: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.TRAP, _source_position[0], _source_position[1])

	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position[0], _source_position[1],
			_target_position[0], _target_position[1])
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			source_mirror[0], source_mirror[1],
			target_mirror[0], target_mirror[1])

	if crystal != null:
		crystal.visible = true

	end_turn = true


func attack() -> void:
	var mirror: Array

	if _pc_hit_target:
		_ref_CountDown.add_count(_new_MirrorData.RESTORE_TURN)
		_create_image_on_the_other_side(
				_target_position[0], _target_position[1])
		_create_image_on_the_same_side(
				_target_position[0], _target_position[1])
	else:
		mirror = _get_mirror(_target_position[0], _target_position[1])
		_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR, mirror[0], mirror[1])
	end_turn = true


func interact_with_trap() -> void:
	var crystal: Sprite
	var mirror: Array

	if _pc_hit_target:
		crystal = _ref_DungeonBoard.get_sprite(
				_new_MainGroupTag.TRAP,
				_target_position[0], _target_position[1])
		crystal.visible = false
	else:
		mirror = _get_mirror(_target_position[0], _target_position[1])
		_ref_RemoveObject.remove(_new_MainGroupTag.TRAP, mirror[0], mirror[1])
	move()


func _is_checkmate() -> bool:
	var npc: Array = _ref_DungeonBoard.get_sprites_by_tag(
			_new_SubGroupTag.PHANTOM)
	var trap: Sprite = _ref_DungeonBoard.get_sprites_by_tag(
			_new_SubGroupTag.CRYSTAL)[0]
	var trap_x: int = _new_ConvertCoord.vector_to_array(trap.position)[0]

	for i in npc:
		if _ref_ObjectData.verify_state(i, _new_ObjectStateTag.DEFAULT):
			return false
	return (_source_position[0] - _new_DungeonSize.CENTER_X) \
			* (trap_x - _new_DungeonSize.CENTER_X) > 0


func _get_mirror(x: int, y: int) -> Array:
	return _new_CoordCalculator.get_mirror_image(
			x, y, _new_DungeonSize.CENTER_X, y)


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
	var actor: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.ACTOR, x, y)
	var trap: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.TRAP, x, y)
	var mirror: Array = _get_mirror(x, y)
	var images: Array
	var remove: int
	var position: Array

	# On this side: Make trap visible. Switch phantom's sprite into default.
	if trap != null:
		trap.visible = true
		_ref_SwitchSprite.switch_sprite(actor, _new_SpriteTypeTag.DEFAULT)

	# On the other side: Remove an existing phantom.
	if _ref_DungeonBoard.has_sprite(
			_new_MainGroupTag.ACTOR, mirror[0], mirror[1]):
		_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR, mirror[0], mirror[1])

	# Move the phantom to the other side. State: passive. Color: grey.
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			x, y, mirror[0], mirror[1])
	_ref_ObjectData.set_state(actor, _new_ObjectStateTag.PASSIVE)
	actor.modulate = _new_Palette.SHADOW

	# On the other side: Remove a trap.
	if _ref_DungeonBoard.has_sprite(
			_new_MainGroupTag.TRAP, mirror[0], mirror[1]):
		_ref_RemoveObject.remove(_new_MainGroupTag.TRAP, mirror[0], mirror[1])

	# There can be at most 5 phantom images.
	images = _ref_DungeonBoard.get_sprites_by_tag(_new_SubGroupTag.PHANTOM)
	_new_ArrayHelper.filter_element(images, self, "_filter_create_image",
			[actor])
	remove = images.size() + 1 - _new_MirrorData.MAX_PHANTOM
	if remove > 0:
		_new_ArrayHelper.rand_picker(images, remove, _ref_RandomNumber)
		for i in images:
			position = _new_ConvertCoord.vector_to_array(i.position)
			_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR,
					position[0], position[1])


func _create_image_on_the_same_side(x: int, y: int) -> void:
	var wall: Array = []
	var mirror: Array
	var actor: Sprite
	var crystal: Sprite

	# Cast a ray to the top.
	wall += _get_mirror_position(x, y, 0, -1, 0)
	# Cast a ray to the bottom.
	wall += _get_mirror_position(x, y, 0, 1, _new_DungeonSize.MAX_Y)
	# Cast a ray to the left.
	wall += _get_mirror_position(x, y, -1, 0, 0)
	# Cast a ray to the right.
	wall += _get_mirror_position(x, y, 1, 0, _new_DungeonSize.MAX_X)

	for i in wall:
		# Continue if the image is outside the dungeon.
		mirror = _new_CoordCalculator.get_mirror_image(x, y, i[0], i[1])
		if mirror.size() == 0:
			continue

		# Continue if there is a building blocks the image.
		if _ref_DungeonBoard.has_sprite(
				_new_MainGroupTag.BUILDING, mirror[0], mirror[1]):
			continue
		# Continue if there is an actor blocks the image.
		elif _ref_DungeonBoard.has_sprite(
				_new_MainGroupTag.ACTOR, mirror[0], mirror[1]):
			continue
		# Continue if the phantom and its image are on different sides.
		elif ((x - _new_DungeonSize.CENTER_X) \
				* (mirror[0] - _new_DungeonSize.CENTER_X)) < 0:
			continue

		# Create a new actor.
		_ref_CreateObject.create(
				_spr_Phantom,
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.PHANTOM,
				mirror[0], mirror[1])

		# Hide the trap and switch the actor's sprite to active.
		if _ref_DungeonBoard.has_sprite(
				_new_MainGroupTag.TRAP, mirror[0], mirror[1]):
			actor = _ref_DungeonBoard.get_sprite(
					_new_MainGroupTag.ACTOR, mirror[0], mirror[1])
			crystal = _ref_DungeonBoard.get_sprite(
					_new_MainGroupTag.TRAP, mirror[0], mirror[1])
			_ref_SwitchSprite.switch_sprite(actor, _new_SpriteTypeTag.ACTIVE)
			crystal.visible = false


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
	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, x, y):
		return 1
	# A building blocks the ray.
	elif _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y):
		# Create a refelection if the building (mirror) is facing the source.
		if _ref_DungeonBoard.has_sprite(
				_new_MainGroupTag.BUILDING, x + x_shift, y + y_shift):
			return 1
		return 2
	# The middle border stops the ray.
	elif x == _new_DungeonSize.CENTER_X:
		return 1
	# Keep casting the ray if nothing happens.
	return 0


func _filter_create_image(source: Array, index: int, opt_arg: Array) -> bool:
	var actor: Sprite = opt_arg[0]

	return (source[index] != actor) \
			and _ref_ObjectData.verify_state(source[index],
					_new_ObjectStateTag.PASSIVE)
