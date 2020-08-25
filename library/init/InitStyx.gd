extends "res://library/init/WorldTemplate.gd"


var _spr_Lighthouse := preload("res://sprite/Lighthouse.tscn")
var _spr_Harbor := preload("res://sprite/Harbor.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_pc()
	_init_building()

	return _blueprint


func _init_floor() -> void:
	pass


func _init_pc() -> void:
	var x: int = 1
	var y: int = _new_DungeonSize.MAX_Y - 2

	_add_to_blueprint(_spr_PC,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC, x, y)


func _init_building() -> void:
	var top_x: int = _new_DungeonSize.MAX_X - 2
	var top_y: int = 1

	_add_to_blueprint(_spr_Lighthouse,
			_new_MainGroupTag.BUILDING, _new_SubGroupTag.LIGHTHOUSE,
			_new_DungeonSize.CENTER_X, _new_DungeonSize.CENTER_Y)
	_add_to_blueprint(_spr_Harbor,
			_new_MainGroupTag.BUILDING, _new_SubGroupTag.HARBOR,
			top_x, top_y)
