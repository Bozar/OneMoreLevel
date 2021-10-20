extends Game_ProgressTemplate


var _spr_Ninja := preload("res://sprite/Ninja.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func end_world(_pc_x: int, _pc_y: int) -> void:
	var count_npc: int

	count_npc = _try_remove_npc()
	_try_respawn_npc(count_npc)


# Remove an idle ninja. Refer: NinjaAI.
func _try_remove_npc() -> int:
	var npcs := _ref_DungeonBoard.get_npc()
	var count_npc := npcs.size()
	var pos: Game_IntCoord

	for i in npcs:
		if _ref_ObjectData.get_hit_point(i) < Game_NinjaData.MAX_NINJA_HP:
			continue
		pos = Game_ConvertCoord.vector_to_coord(i.position)
		_ref_RemoveObject.remove_actor(pos.x, pos.y)
		count_npc -= 1
	return count_npc


func _try_respawn_npc(count_npc: int) -> void:
	var respawn: int
	var region := []
	var actor: Sprite

	respawn = Game_NinjaData.MAX_NINJA - count_npc
	respawn = min(respawn, Game_NinjaData.MAX_NINJA_PER_LEVEL) as int
	if respawn < 1:
		return

	for x in range(Game_NinjaData.MIN_X, Game_NinjaData.MAX_X):
		for y in range(Game_NinjaData.MIN_Y, Game_NinjaData.LEVEL_1_Y):
			if _ref_DungeonBoard.has_actor(x, y):
				continue
			region.push_back(Game_IntCoord.new(x, y))

	respawn = min(respawn, region.size()) as int
	if respawn < 1:
		return
	Game_ArrayHelper.rand_picker(region, respawn, _ref_RandomNumber)

	for i in region:
		actor = _ref_CreateObject.create_and_fetch_actor(_spr_Ninja,
				Game_SubTag.NINJA, i.x, i.y)
		_ref_ObjectData.set_bool(actor, true)
