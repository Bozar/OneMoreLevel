extends "res://library/init/WorldTemplate.gd"


var _spr_CrystalBase := preload("res://sprite/CrystalBase.tscn")

var _new_MirrorData := preload("res://library/npc_data/MirrorData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_middle_border()
	_init_pc()

	return _blueprint


func _init_middle_border() -> void:
	var crystal_base: Array = [
		_new_MirrorData.CENTER_Y_1,
		_new_MirrorData.CENTER_Y_2,
		_new_MirrorData.CENTER_Y_3,
		_new_MirrorData.CENTER_Y_4,
		_new_MirrorData.CENTER_Y_5,
	]
	var new_sprite: PackedScene
	var sub_group_tag: String

	for i in range(_new_DungeonSize.MAX_Y):
		if i in crystal_base:
			new_sprite = _spr_CrystalBase
			sub_group_tag = _new_SubGroupTag.CRYSTAL_BASE
		else:
			new_sprite = _spr_Wall
			sub_group_tag = _new_SubGroupTag.WALL

		_add_to_blueprint(new_sprite,
				_new_MainGroupTag.BUILDING, sub_group_tag,
				_new_DungeonSize.CENTER_X, i)
		_occupy_position(_new_DungeonSize.CENTER_X, i)


func _init_pc() -> void:
	_add_to_blueprint(_spr_PC,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC,
			0, 0)
