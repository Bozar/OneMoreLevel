extends Game_ProgressTemplate


const MIN_TRAP := -99
const SHADOW_AS_TRAP := 5

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
	Game_ArrayHelper.shuffle(region, _ref_RandomNumber)

	if respawn_shadow:
		_move_shadow_to_start(region)
	for i in range(0, respawn):
		if (i == 0) and respawn_shadow:
			new_scene = _spr_NinjaShadow
			sub_tag = Game_SubTag.NINJA_SHADOW
		else:
			new_scene = _spr_Ninja
			sub_tag = Game_SubTag.NINJA
		actor = _ref_CreateObject.create_and_fetch_actor_xy(new_scene,
				sub_tag, region[i].x, region[i].y)
		_ref_ObjectData.set_bool(actor, true)


func _move_shadow_to_start(respawn_coords: Array) -> void:
	var coord: Game_IntCoord
	var has_trap: int
	var max_trap := MIN_TRAP
	var x_to_trap := {}
	var save_index := []

	for i in range(0, respawn_coords.size()):
		coord = respawn_coords[i]
		if not x_to_trap.has(coord.x):
			x_to_trap[coord.x] = _count_traps(coord.x)
		has_trap = x_to_trap[coord.x]
		if has_trap > max_trap:
			max_trap = has_trap
			save_index.clear()
			save_index.push_back(i)
		elif has_trap == max_trap:
			save_index.push_back(i)

	Game_ArrayHelper.rand_picker(save_index, 1, _ref_RandomNumber)
	Game_ArrayHelper.swap_element(respawn_coords, 0, save_index[0])


func _count_traps(this_x: int) -> int:
	var count := 0

	for y in range(0, Game_NinjaData.MAX_Y):
		if _ref_DungeonBoard.has_trap_xy(this_x, y):
			count += 1
		# Prevent shadow ninjas from stacking on each other.
		elif _ref_DungeonBoard.has_sprite_with_sub_tag_xy(
				Game_SubTag.NINJA_SHADOW, this_x, y):
			count -= SHADOW_AS_TRAP
	return count
