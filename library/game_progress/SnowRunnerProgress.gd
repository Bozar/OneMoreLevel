extends Game_ProgressTemplate


var _is_first_turn := true
var _doors: Array


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func renew_world(_pc_x: int, _pc_y: int) -> void:
	_init_doors()


# func end_world(_pc_x: int, _pc_y: int) -> void:
# 	for i in _doors:
# 		if _ref_ObjectData.get_hit_point(i) < Game_SnowRunnerData.DEFAULT_DOOR:
# 			_ref_ObjectData.add_hit_point(i, 1)
# 			if _ref_ObjectData.get_hit_point(i) \
# 					== Game_SnowRunnerData.DEFAULT_DOOR:
# 				_ref_SwitchSprite.set_sprite(i, Game_SpriteTypeTag.DEFAULT)


func create_building(building: Sprite, sub_tag: String, _x: int, _y: int) \
		-> void:
	if sub_tag == Game_SubTag.DOOR:
		_doors.push_back(building)


func _init_doors() -> void:
	if not _is_first_turn:
		return
	_is_first_turn = false

	_ref_ObjectData.set_state(_doors[1], Game_StateTag.ACTIVE)
	_ref_SwitchSprite.set_sprite(_doors[1], Game_SpriteTypeTag.ACTIVE)

	_ref_ObjectData.set_state(_doors[0], Game_StateTag.ACTIVE)
	_ref_SwitchSprite.set_sprite(_doors[0], Game_SpriteTypeTag.ACTIVE)
