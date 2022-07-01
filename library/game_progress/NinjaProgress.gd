extends Game_ProgressTemplate


var _spr_Ninja := preload("res://sprite/Ninja.tscn")
var _spr_NinjaShadow := preload("res://sprite/NinjaShadow.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func end_world(_pc_x: int, _pc_y: int) -> void:
	var count_npc := _try_remove_npc()
	var count_shadow := _ref_DungeonBoard.get_sprites_by_tag(
			Game_SubTag.NINJA_SHADOW).size()
	var respawn_shadow := count_shadow < Game_NinjaData.MAX_SHADOW_NINJA

	_try_respawn_npc(count_npc, respawn_shadow)


# Remove an idle ninja. Refer: NinjaAI.
func _try_remove_npc() -> int:
	var npcs := _ref_DungeonBoard.get_npc()
	var count_npc := npcs.size()
	var pos: Game_IntCoord

	for i in npcs:
		if _ref_ObjectData.get_hit_point(i) < Game_NinjaData.MAX_NINJA_HP:
			continue
		pos = Game_ConvertCoord.sprite_to_coord(i)
		_ref_RemoveObject.remove_actor(pos)
		count_npc -= 1
	return count_npc


func _try_respawn_npc(count_npc: int, respawn_shadow: bool) -> void:
	var respawn: int
	var region := []
	var shadow_index := -1
	var new_scene: PackedScene
	var sub_tag: String
	var actor: Sprite

	respawn = Game_NinjaData.MAX_NINJA - count_npc
	respawn = min(respawn, Game_NinjaData.MAX_NINJA_PER_LEVEL) as int
	if respawn < 1:
		return

	for x in range(Game_NinjaData.MIN_X, Game_NinjaData.MAX_X):
		for y in range(Game_NinjaData.MIN_Y, Game_NinjaData.LEVEL_1_Y):
			if _ref_DungeonBoard.has_actor_xy(x, y):
				continue
			region.push_back(Game_IntCoord.new(x, y))

	respawn = min(respawn, region.size()) as int
	if respawn < 1:
		return
	Game_ArrayHelper.rand_picker(region, respawn, _ref_RandomNumber)

	if respawn_shadow:
		shadow_index = _ref_RandomNumber.get_int(0, region.size())
	for i in region.size():
		if i == shadow_index:
			new_scene = _spr_NinjaShadow
			sub_tag = Game_SubTag.NINJA_SHADOW
		else:
			new_scene = _spr_Ninja
			sub_tag = Game_SubTag.NINJA
		actor = _ref_CreateObject.create_and_fetch_actor_xy(new_scene,
				sub_tag, region[i].x, region[i].y)
		_ref_ObjectData.set_bool(actor, true)
