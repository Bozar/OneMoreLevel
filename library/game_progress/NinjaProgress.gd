extends Game_ProgressTemplate


# var _spr_Ninja := preload("res://sprite/Ninja.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


# func end_world(pc_x: int, pc_y: int) -> void:
# 	_respawn_npc(pc_x, pc_y)
# 	_try_remove_trap()


# func _respawn_npc(pc_x: int, pc_y: int) -> void:
# 	var respawn_counter: int = Game_NinjaData.MAX_NPC \
# 			- _ref_DungeonBoard.count_npc()
# 	var neighbor: Array

# 	if respawn_counter == 0:
# 		return

# 	neighbor = Game_CoordCalculator.get_neighbor(pc_x, pc_y,
# 			Game_NinjaData.MAX_DISTANCE_TO_PC)
# 	Game_ArrayHelper.filter_element(neighbor, self, "_not_too_close_to_pc",
# 			[pc_x, pc_y])
# 	Game_ArrayHelper.rand_picker(neighbor, respawn_counter, _ref_RandomNumber)

# 	for i in neighbor:
# 		_ref_CreateObject.create_actor(_spr_Ninja, Game_SubTag.NINJA,
# 				i[0], i[1])


# func _not_too_close_to_pc(source: Array, index: int, opt_arg: Array) -> bool:
# 	var x: int = source[index][0]
# 	var y: int = source[index][1]
# 	var pc_x: int = opt_arg[0]
# 	var pc_y: int = opt_arg[1]

# 	return not (_ref_DungeonBoard.has_building(x, y) \
# 			or _ref_DungeonBoard.has_actor(x, y)
# 			or Game_CoordCalculator.is_inside_range(x, y, pc_x, pc_y,
# 					Game_NinjaData.MIN_DISTANCE_TO_PC))


# func _try_remove_trap() -> void:
# 	var find_traps: Array = _ref_DungeonBoard.get_sprites_by_tag(
# 			Game_MainTag.TRAP)
# 	var remove_position: Array = []

# 	for i in find_traps:
# 		if _ref_ObjectData.get_hit_point(i) == Game_NinjaData.MAX_SOUL_DURATION:
# 			remove_position.push_back(Game_ConvertCoord.vector_to_array(
# 					i.position))
# 		elif _ref_ObjectData.get_hit_point(i) \
# 				== Game_NinjaData.MAX_SOUL_DURATION - 1:
# 			_ref_SwitchSprite.switch_sprite(i, Game_SpriteTypeTag.PASSIVE)
# 		_ref_ObjectData.add_hit_point(i, 1)

# 	for i in remove_position:
# 		_ref_RemoveObject.remove_trap(i[0], i[1])
