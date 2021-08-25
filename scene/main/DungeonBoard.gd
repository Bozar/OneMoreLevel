extends Node2D
class_name Game_DungeonBoard


# <main_group: String, <column: int, [sprite]>>
var _sprite_dict: Dictionary
var _pc: Sprite

var _sub_group_to_sprite: Dictionary = {
	Game_SubGroupTag.ARROW_RIGHT: null,
	Game_SubGroupTag.ARROW_DOWN: null,
	Game_SubGroupTag.ARROW_UP: null,
}


func _ready() -> void:
	_init_dict()


func has_sprite(main_group: String, x: int, y: int) -> bool:
	if not Game_CoordCalculator.is_inside_dungeon(x, y):
		return false
	if not _sprite_dict.has(main_group):
		return false
	if not _sprite_dict[main_group].has(x):
		return false
	return _sprite_dict[main_group][x][y] != null


func has_sprite_with_sub_tag(sub_group: String, x: int, y: int) -> bool:
	var find_sprite: Sprite

	for i in Game_MainGroupTag.DUNGEON_OBJECT:
		find_sprite = get_sprite(i, x, y)
		if (find_sprite != null) and find_sprite.is_in_group(sub_group):
			return true
	return false


func get_sprite(main_group: String, x: int, y: int) -> Sprite:
	if has_sprite(main_group, x, y):
		return _sprite_dict[main_group][x][y]
	return null


# There should be only one sprite in the group `Game_SubGroupTag.PC`.
# The PC sprite should not be removed throughout the game.
func get_pc() -> Sprite:
	var find_pc: Array

	if _pc == null:
		find_pc = get_sprites_by_tag(Game_SubGroupTag.PC)
		if find_pc.size() > 0:
			_pc = find_pc[0]
	return _pc


func get_npc() -> Array:
	var npc: Array = get_sprites_by_tag(Game_MainGroupTag.ACTOR)
	Game_ArrayHelper.filter_element(npc, self, "_filter_get_npc", [])
	return npc


func count_npc() -> int:
	return get_npc().size()


# When we call `foobar.queue_free()`, the node foobar will be deleted at the end
# of the current frame if there are no references to it.
#
# However, if we set a reference to foobar in the same frame by, let's say,
# `get_tree().get_nodes_in_group()`, foobar will not be deleted when the current
# frame ends.
#
# Therefore, after calling `get_tree().get_nodes_in_group()`, we need to check
# if such nodes will be deleted with `foobar.is_queued_for_deletion()` to avoid
# potential bugs.
#
# You can reproduce such a bug in v0.1.3 with the seed 1888400396. Refer to this
# video for more information.
#
# https://youtu.be/agqdag6GqpU
func get_sprites_by_tag(group_tag: String) -> Array:
	var sprites: Array = get_tree().get_nodes_in_group(group_tag)
	# var verify: Sprite
	# var counter: int = 0

	# Filter elements in a more efficent way based on `u/kleonc`'s suggestion.
	# https://www.reddit.com/r/godot/comments/kq4c91/beware_that_foobarqueue_free_removes_foobar_at/gi3femf
	# for i in range(sprites.size()):
	# 	verify = sprites[i]
	# 	if verify.is_queued_for_deletion():
	# 		continue
	# 	sprites[counter] = verify
	# 	counter += 1
	# sprites.resize(counter)
	Game_ArrayHelper.filter_element(sprites, self, "_filter_get_sprites_by_tag",
			[])
	return sprites
	# return get_tree().get_nodes_in_group(group_tag)


func get_actor(x: int, y: int) -> Sprite:
	return get_sprite(Game_MainGroupTag.ACTOR, x, y)


func has_actor(x: int, y: int) -> bool:
	return has_sprite(Game_MainGroupTag.ACTOR, x, y)


func get_building(x: int, y: int) -> Sprite:
	return get_sprite(Game_MainGroupTag.BUILDING, x, y)


func has_building(x: int, y: int) -> bool:
	return has_sprite(Game_MainGroupTag.BUILDING, x, y)


func get_trap(x: int, y: int) -> Sprite:
	return get_sprite(Game_MainGroupTag.TRAP, x, y)


func has_trap(x: int, y: int) -> bool:
	return has_sprite(Game_MainGroupTag.TRAP, x, y)


func get_ground(x: int, y: int) -> Sprite:
	return get_sprite(Game_MainGroupTag.GROUND, x, y)


func has_ground(x: int, y: int) -> bool:
	return has_sprite(Game_MainGroupTag.GROUND, x, y)


func move_sprite(main_group: String, source_x: int, source_y: int,
		target_x: int, target_y: int) -> void:
	var sprite: Sprite = get_sprite(main_group, source_x, source_y)
	if sprite == null:
		return

	_sprite_dict[main_group][source_x][source_y] = null
	_sprite_dict[main_group][target_x][target_y] = sprite
	sprite.position = Game_ConvertCoord.index_to_vector(target_x, target_y)

	_try_move_arrow(sprite)


func swap_sprite(main_group: String, source_x: int, source_y: int,
		target_x: int, target_y: int) -> void:
	var source_sprite: Sprite = get_sprite(main_group, source_x, source_y)
	var target_sprite: Sprite = get_sprite(main_group, target_x, target_y)

	if (source_sprite == null) or (target_sprite == null):
		return

	_sprite_dict[main_group][source_x][source_y] = target_sprite
	_sprite_dict[main_group][target_x][target_y] = source_sprite

	source_sprite.position = Game_ConvertCoord.index_to_vector(
			target_x, target_y)
	target_sprite.position = Game_ConvertCoord.index_to_vector(
			source_x, source_y)

	_try_move_arrow(source_sprite)
	_try_move_arrow(target_sprite)


func _on_CreateObject_sprite_created(new_sprite: Sprite,
		main_group: String, sub_group: String, _x: int, _y: int) -> void:
	var pos: Array

	# Save references to arrow indicators.
	if main_group == Game_MainGroupTag.INDICATOR:
		for i in _sub_group_to_sprite.keys():
			if i == sub_group:
				_sub_group_to_sprite[i] = new_sprite
		return

	# Save references to dungeon sprites.
	for i in Game_MainGroupTag.DUNGEON_OBJECT:
		if i == main_group:
			pos = Game_ConvertCoord.vector_to_array(new_sprite.position)
			_sprite_dict[i][pos[0]][pos[1]] = new_sprite
			return


func _on_RemoveObject_sprite_removed(_sprite: Sprite, main_group: String,
		x: int, y: int) -> void:
	_sprite_dict[main_group][x][y] = null


func _init_dict() -> void:
	for i in Game_MainGroupTag.DUNGEON_OBJECT:
		_sprite_dict[i] = {}
		for x in range(Game_DungeonSize.MAX_X):
			_sprite_dict[i][x] = []
			_sprite_dict[i][x].resize(Game_DungeonSize.MAX_Y)


# Move arrow indicators when PC moves.
func _try_move_arrow(sprite: Sprite) -> void:
	if not sprite.is_in_group(Game_SubGroupTag.PC):
		return

	_sub_group_to_sprite[Game_SubGroupTag.ARROW_RIGHT] \
			.position.y = sprite.position.y
	_sub_group_to_sprite[Game_SubGroupTag.ARROW_DOWN] \
			.position.x = sprite.position.x
	_sub_group_to_sprite[Game_SubGroupTag.ARROW_UP] \
			.position.x = sprite.position.x


func _filter_get_sprites_by_tag(source: Array, index: int,
		_opt_arg: Array) -> bool:
	return not source[index].is_queued_for_deletion()


func _filter_get_npc(source: Array, index: int, _opt_arg: Array) -> bool:
	return not (source[index].is_queued_for_deletion() \
			or source[index].is_in_group(Game_SubGroupTag.PC))
