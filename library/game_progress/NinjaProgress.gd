extends Game_ProgressTemplate


var _spr_Ninja := preload("res://sprite/Ninja.tscn")
var _spr_NinjaButterfly := preload("res://sprite/NinjaButterfly.tscn")
var _spr_NinjaShadow := preload("res://sprite/NinjaShadow.tscn")

var _respawn_position: Array = []


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func end_world(pc_x: int, pc_y: int) -> void:
	_respawn_npc(pc_x, pc_y)


func _respawn_npc(pc_x: int, pc_y: int) -> void:
	var respawn_ground: Array
	var all_npcs: Array = _ref_DungeonBoard.get_npc()
	var minion: int = Game_NinjaData.MAX_MINION
	var butterfly: int = Game_NinjaData.MAX_BUTTERFLY
	var shadow: int = Game_NinjaData.MAX_SHADOW
	var new_ninja: PackedScene
	var new_sub_tag: String

	if _respawn_position.size() == 0:
		respawn_ground = _ref_DungeonBoard.get_sprites_by_tag(
				Game_SubGroupTag.RESPAWN)
		for i in respawn_ground:
			_respawn_position.push_back(_new_ConvertCoord.vector_to_array(
					i.position))

	for i in all_npcs:
		if i.is_in_group(Game_SubGroupTag.NINJA):
			minion -= 1
		elif i.is_in_group(Game_SubGroupTag.BUTTERFLY_NINJA):
			butterfly -= 1
		elif i.is_in_group(Game_SubGroupTag.SHADOW_NINJA):
			shadow -= 1

	if minion + butterfly + shadow == 0:
		return
	_new_ArrayHelper.rand_picker(_respawn_position, _respawn_position.size(),
			_ref_RandomNumber)

	for i in _respawn_position:
		if _ref_DungeonBoard.has_sprite(Game_MainGroupTag.ACTOR, i[0], i[1]):
			continue
		elif _new_CoordCalculator.is_inside_range(i[0], i[1], pc_x, pc_y, 1):
			continue
		else:
			if minion > 0:
				minion -= 1
				new_ninja = _spr_Ninja
				new_sub_tag = Game_SubGroupTag.NINJA
			elif butterfly > 0:
				butterfly -= 1
				new_ninja = _spr_NinjaButterfly
				new_sub_tag = Game_SubGroupTag.BUTTERFLY_NINJA
			elif shadow > 0:
				shadow -= 1
				new_ninja = _spr_NinjaShadow
				new_sub_tag = Game_SubGroupTag.SHADOW_NINJA
			else:
				return
		_ref_CreateObject.create(new_ninja,
				Game_MainGroupTag.ACTOR, new_sub_tag, i[0], i[1])
