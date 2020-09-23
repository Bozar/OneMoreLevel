extends "res://library/game_progress/ProgressTemplate.gd"


var _spr_Crystal := preload("res://sprite/Crystal.tscn")

var _new_MirrorData := preload("res://library/npc_data/MirrorData.gd").new()

var _create_first_crystal: bool = true


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func renew_world(pc_x: int, pc_y: int) -> void:
	if _create_first_crystal:
		_init_crystal(pc_x, pc_y)
		_create_first_crystal = false


func remove_npc(_npc: Sprite, _x: int, _y: int) -> void:
	pass


func remove_building(_building: Sprite, _x: int, _y: int) -> void:
	pass


func remove_trap(_trap: Sprite, _x: int, _y: int) -> void:
	print("remove trap")


func _init_crystal(pc_x: int, pc_y: int) -> void:
	var x: int
	var y: int

	while true:
		x = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
		y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)

		if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y) \
				or _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, x, y) \
				or _new_CoordCalculator.is_inside_range(
						x, y, pc_x, pc_y, _new_MirrorData.CRYSTAL_DISTANCE):
			continue
		break

	_ref_CreateObject.create(_spr_Crystal,
			_new_MainGroupTag.TRAP, _new_SubGroupTag.CRYSTAL,
			x, y)
	_ref_DangerZone.set_danger_zone(x, y, true)
