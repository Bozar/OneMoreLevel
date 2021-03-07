extends "res://library/game_progress/ProgressTemplate.gd"


var _spr_Demon := preload("res://sprite/Demon.tscn")

var _new_RailgunData := preload("res://library/npc_data/RailgunData.gd").new()

var _min_npc: int = _new_RailgunData.MIN_NPC
var _alive_npc: int = _new_RailgunData.MIN_NPC


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func end_world(pc_x: int, pc_y: int) -> void:
	if _min_npc - _alive_npc < _new_RailgunData.TRIGGER_RESPAWN:
		return
	if _min_npc < _new_RailgunData.MAX_NPC:
		_min_npc += _new_RailgunData.RESPAWN
		_min_npc = min(_min_npc, _new_RailgunData.MAX_NPC) as int
	while _alive_npc < _min_npc:
		_respawn_npc(pc_x, pc_y)
		_alive_npc += 1


func remove_actor(_actor: Sprite, _x: int, _y: int) -> void:
	_alive_npc -= 1
	_alive_npc = max(_alive_npc, 0) as int


func _respawn_npc(pc_x: int, pc_y: int) -> void:
	var x: int
	var y: int

	while true:
		x = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
		y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)

		if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y) \
				or _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, x, y):
			continue
		elif _new_CoordCalculator.is_inside_range(x, y, pc_x, pc_y,
				_new_RailgunData.PC_FRONT_SIGHT):
			continue
		break

	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.TRAP, x, y):
		_ref_RemoveObject.remove(_new_MainGroupTag.TRAP, x, y)
	_ref_CreateObject.create(_spr_Demon,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.DEMON, x, y)
