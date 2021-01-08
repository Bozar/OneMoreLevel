extends "res://library/game_progress/ProgressTemplate.gd"


var _spr_Frog := preload("res://sprite/Frog.tscn")
var _spr_FrogPrincess := preload("res://sprite/FrogPrincess.tscn")
var _spr_Floor := preload("res://sprite/Floor.tscn")

var _new_FrogData := preload("res://library/npc_data/FrogData.gd").new()
var _new_ArrayHelper := preload("res://library/ArrayHelper.gd").new()

# wave counter:
# 0: 8 frogs
# 1: princess, submerge land
# 2: 8 frogs
# 3: princess, 4 frogs, submerge land
var _wave_counter: int = 0


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func renew_world(_pc_x: int, _pc_y: int) -> void:
	if _wave_counter == 0:
		_create_frog()
		_wave_counter += 1


func remove_actor(_actor: Sprite, _x: int, _y: int) -> void:
	print("remove actor")


func _create_frog() -> void:
	_ref_CreateObject.create(_spr_Frog,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.FROG, 0, 0)


func _submerge_land() -> void:
	var land_sprite: Array = _ref_DungeonBoard.get_sprites_by_tag(
			_new_SubGroupTag.LAND)
	var land_pos: Array
	var x: int
	var y: int

	_new_ArrayHelper.random_picker(land_sprite, _new_FrogData.SUBMERGE_LAND,
			_ref_RandomNumber)

	for i in land_sprite:
		land_pos = _new_ConvertCoord.vector_to_array(i.position)
		x = land_pos[0]
		y = land_pos[1]

		_ref_RemoveObject.remove(_new_MainGroupTag.GROUND, x, y)
		_ref_CreateObject.create(_spr_Floor,
				_new_MainGroupTag.GROUND, _new_SubGroupTag.FLOOR, x, y)
