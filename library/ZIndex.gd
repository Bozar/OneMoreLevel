var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()

var _main_group_to_z_index: Dictionary = {
	_new_MainGroupTag.INVALID: -100,
	_new_MainGroupTag.GROUND: 0,
	_new_MainGroupTag.TRAP: 1,
	_new_MainGroupTag.BUILDING: 2,
	_new_MainGroupTag.ACTOR: 3,
	_new_MainGroupTag.INDICATOR: 4,
}


func get_z_index(main_tag: String) -> int:
	if not _main_group_to_z_index.has(main_tag):
		main_tag = _new_MainGroupTag.INVALID
	return _main_group_to_z_index[main_tag]
