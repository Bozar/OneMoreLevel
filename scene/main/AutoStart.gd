extends Node2D
class_name Game_AutoStart


var _started: bool = false
var _path_to_init: String = "../InitWorld"


func _process(_delta) -> void:
	if _started:
		queue_free()
		return

	get_node(_path_to_init).init_world()
	_started = true
