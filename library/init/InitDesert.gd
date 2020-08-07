extends "res://library/init/WorldTemplate.gd"


var _spr_PC := preload("res://sprite/PC.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_add_to_blueprint(_spr_PC,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC,
			0, 0)

	return _blueprint
