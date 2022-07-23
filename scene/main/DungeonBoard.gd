extends Node2D
class_name Game_DungeonBoard


const ERR_SPRITE := ": MainTag: {0}, Coord: ({1}, {2}), Layer: {3}."
const ERR_NO_SPRITE := "No sprite" + ERR_SPRITE
const ERR_HAS_SPRITE := "Has sprite" + ERR_SPRITE

# <main_tag: String, <column: int, [sprite]>>
var _sprite_dict: Dictionary
var _pc: Sprite

var _sub_tag_to_sprite: Dictionary = {
	Game_SubTag.ARROW_RIGHT: null,
	Game_SubTag.ARROW_DOWN: null,
	Game_SubTag.ARROW_UP: null,
}


func _ready() -> void:
	pass


func has_sprite_xy(main_tag: String, x: int, y: int, sprite_layer := 0) -> bool:
	return get_sprite_xy(main_tag, x, y, sprite_layer) != null


func has_sprite(main_tag: String, coord: Game_IntCoord, sprite_layer := 0) \
		-> bool:
	return has_sprite_xy(main_tag, coord.x, coord.y, sprite_layer)


func has_sprite_with_sub_tag_xy(main_tag: String, sub_tag: String,
		x: int, y: int, sprite_layer := 0) -> bool:
	var find_sprite: Sprite
	var find_in_main_tags: Array

	if main_tag == "":
		find_in_main_tags = Game_MainTag.DUNGEON_OBJECT
	else:
		find_in_main_tags = [main_tag]

	for i in find_in_main_tags:
		find_sprite = get_sprite_xy(i, x, y, sprite_layer)
		if (find_sprite != null) and find_sprite.is_in_group(sub_tag):
			return true
	return false


func has_sprite_with_sub_tag(main_tag: String, sub_tag: String,
		coord: Game_IntCoord, sprite_layer := 0) -> bool:
	return has_sprite_with_sub_tag_xy(main_tag, sub_tag, coord.x, coord.y,
			sprite_layer)


func get_sprite_xy(main_tag: String, x: int, y: int, sprite_layer := 0) \
		-> Sprite:
	main_tag = _try_convert_main_tag(main_tag, sprite_layer)

	if not Game_CoordCalculator.is_inside_dungeon(x, y):
		return null
	elif not _sprite_dict.has(main_tag):
		return null
	elif not _sprite_dict[main_tag].has(x):
		return null
	return _sprite_dict[main_tag][x][y]


func get_sprite(main_tag: String, coord: Game_IntCoord, sprite_layer := 0) \
		-> Sprite:
	return get_sprite_xy(main_tag, coord.x, coord.y, sprite_layer)


# There should be only one sprite in the group `Game_SubTag.PC`.
# The PC sprite should not be removed throughout the game.
func get_pc() -> Sprite:
	var find_pc: Array

	if _pc == null:
		find_pc = get_sprites_by_tag(Game_SubTag.PC)
		if find_pc.size() > 0:
			_pc = find_pc[0]
	return _pc


func get_pc_coord() -> Game_IntCoord:
	return Game_ConvertCoord.sprite_to_coord(get_pc())


func get_npc() -> Array:
	var npc: Array = get_sprites_by_tag(Game_MainTag.ACTOR)
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
func get_sprites_by_tag(tag: String) -> Array:
	var sprites: Array = get_tree().get_nodes_in_group(tag)
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
	# return get_tree().get_nodes_in_group(tag)


func get_actor_xy(x: int, y: int, sprite_layer := 0) -> Sprite:
	return get_sprite_xy(Game_MainTag.ACTOR, x, y, sprite_layer)


func has_actor_xy(x: int, y: int, sprite_layer := 0) -> bool:
	return has_sprite_xy(Game_MainTag.ACTOR, x, y, sprite_layer)


func get_actor(coord: Game_IntCoord, sprite_layer := 0) -> Sprite:
	return get_actor_xy(coord.x, coord.y, sprite_layer)


func has_actor(coord: Game_IntCoord, sprite_layer := 0) -> bool:
	return has_actor_xy(coord.x, coord.y, sprite_layer)


func get_building_xy(x: int, y: int) -> Sprite:
	return get_sprite_xy(Game_MainTag.BUILDING, x, y)


func has_building_xy(x: int, y: int) -> bool:
	return has_sprite_xy(Game_MainTag.BUILDING, x, y)


func get_building(coord: Game_IntCoord) -> Sprite:
	return get_building_xy(coord.x, coord.y)


func has_building(coord: Game_IntCoord) -> bool:
	return has_building_xy(coord.x, coord.y)


func get_trap_xy(x: int, y: int) -> Sprite:
	return get_sprite_xy(Game_MainTag.TRAP, x, y)


func has_trap_xy(x: int, y: int) -> bool:
	return has_sprite_xy(Game_MainTag.TRAP, x, y)


func get_trap(coord: Game_IntCoord) -> Sprite:
	return get_trap_xy(coord.x, coord.y)


func has_trap(coord: Game_IntCoord) -> bool:
	return has_trap_xy(coord.x, coord.y)


func get_ground_xy(x: int, y: int) -> Sprite:
	return get_sprite_xy(Game_MainTag.GROUND, x, y)


func has_ground_xy(x: int, y: int) -> bool:
	return has_sprite_xy(Game_MainTag.GROUND, x, y)


func get_ground(coord: Game_IntCoord) -> Sprite:
	return get_ground_xy(coord.x, coord.y)


func has_ground(coord: Game_IntCoord) -> bool:
	return has_ground_xy(coord.x, coord.y)


func move_sprite_xy(main_tag: String, source_x: int, source_y: int,
		target_x: int, target_y: int, sprite_layer := 0) -> void:
	var move_this := get_sprite_xy(main_tag, source_x, source_y, sprite_layer)

	if move_this == null:
		push_error(ERR_NO_SPRITE.format([main_tag, source_x, source_y,
				sprite_layer]))
		return
	elif has_sprite_xy(main_tag, target_x, target_y, sprite_layer):
		push_error(ERR_HAS_SPRITE.format([main_tag, target_x, target_y,
				sprite_layer]))
		return

	main_tag = _try_convert_main_tag(main_tag, sprite_layer)
	_sprite_dict[main_tag][source_x][source_y] = null
	_sprite_dict[main_tag][target_x][target_y] = move_this
	move_this.position = Game_ConvertCoord.coord_to_vector(target_x, target_y)

	_try_move_arrow(move_this)


func move_sprite(main_tag: String, source: Game_IntCoord, target: Game_IntCoord,
		sprite_layer := 0) -> void:
	move_sprite_xy(main_tag, source.x, source.y, target.x, target.y,
			sprite_layer)


func move_actor_xy(source_x: int, source_y: int, target_x: int, target_y: int,
		sprite_layer := 0) -> void:
	move_sprite_xy(Game_MainTag.ACTOR, source_x, source_y, target_x, target_y,
			sprite_layer)


func move_actor(source: Game_IntCoord, target: Game_IntCoord,
		sprite_layer := 0) -> void:
	move_actor_xy(source.x, source.y, target.x, target.y, sprite_layer)


func swap_sprite_xy(main_tag: String, source_x: int, source_y: int,
		target_x: int, target_y: int, sprite_layer := 0) -> void:
	var source_sprite := get_sprite_xy(main_tag, source_x, source_y,
			sprite_layer)
	var target_sprite := get_sprite_xy(main_tag, target_x, target_y,
			sprite_layer)

	if (source_sprite == null) or (target_sprite == null):
		return

	main_tag = _try_convert_main_tag(main_tag, sprite_layer)
	_sprite_dict[main_tag][source_x][source_y] = target_sprite
	_sprite_dict[main_tag][target_x][target_y] = source_sprite

	source_sprite.position = Game_ConvertCoord.coord_to_vector(
			target_x, target_y)
	target_sprite.position = Game_ConvertCoord.coord_to_vector(
			source_x, source_y)

	_try_move_arrow(source_sprite)
	_try_move_arrow(target_sprite)


func swap_sprite(main_tag: String, source: Game_IntCoord, target: Game_IntCoord,
		 sprite_layer := 0) -> void:
	swap_sprite_xy(main_tag, source.x, source.y, target.x, target.y,
			sprite_layer)


func _on_CreateObject_sprite_created(new_sprite: Sprite, main_tag: String,
		sub_tag: String, _x: int, _y: int, sprite_layer: int) -> void:
	var pos: Game_IntCoord
	var new_tag: String

	# Save references to arrow indicators.
	if main_tag == Game_MainTag.INDICATOR:
		for i in _sub_tag_to_sprite.keys():
			if i == sub_tag:
				_sub_tag_to_sprite[i] = new_sprite
	# Save references to dungeon sprites.
	else:
		for i in Game_MainTag.DUNGEON_OBJECT:
			if i != main_tag:
				continue
			new_tag = _try_convert_main_tag(i, sprite_layer)
			if not _sprite_dict.has(new_tag):
				_init_dict(new_tag)
			pos = Game_ConvertCoord.sprite_to_coord(new_sprite)
			_sprite_dict[new_tag][pos.x][pos.y] = new_sprite


func _on_RemoveObject_sprite_removed(_sprite: Sprite, main_tag: String,
		x: int, y: int, sprite_layer: int) -> void:
	main_tag = _try_convert_main_tag(main_tag, sprite_layer)
	_sprite_dict[main_tag][x][y] = null


func _init_dict(new_tag: String) -> void:
	_sprite_dict[new_tag] = {}
	for x in range(Game_DungeonSize.MAX_X):
		_sprite_dict[new_tag][x] = []
		_sprite_dict[new_tag][x].resize(Game_DungeonSize.MAX_Y)


# Move arrow indicators when PC moves.
func _try_move_arrow(sprite: Sprite) -> void:
	if not sprite.is_in_group(Game_SubTag.PC):
		return

	_sub_tag_to_sprite[Game_SubTag.ARROW_RIGHT].position.y = sprite.position.y
	_sub_tag_to_sprite[Game_SubTag.ARROW_DOWN].position.x = sprite.position.x
	_sub_tag_to_sprite[Game_SubTag.ARROW_UP].position.x = sprite.position.x


func _filter_get_sprites_by_tag(source: Array, index: int,
		_opt_arg: Array) -> bool:
	return not source[index].is_queued_for_deletion()


func _filter_get_npc(source: Array, index: int, _opt_arg: Array) -> bool:
	return not (source[index].is_queued_for_deletion() \
			or source[index].is_in_group(Game_SubTag.PC))


func _try_convert_main_tag(main_tag: String, sprite_layer: int) -> String:
	return main_tag \
			if sprite_layer == 0 \
			else main_tag + "_" + String(sprite_layer)
