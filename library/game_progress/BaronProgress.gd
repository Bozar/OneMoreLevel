extends Game_ProgressTemplate


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func renew_world(_pc_x: int, _pc_y: int) -> void:
	pass


func remove_actor(_actor: Sprite, _x: int, _y: int) -> void:
	print("remove actor")


func create_actor(actor: Sprite, sub_tag: String, x: int, y: int) -> void:
	if sub_tag != Game_SubTag.BIRD:
		return

	var building := _ref_DungeonBoard.get_building(x, y)

	if building.is_in_group(Game_SubTag.TREE_BRANCH):
		_ref_SwitchSprite.set_sprite(actor, Game_SpriteTypeTag.ACTIVE)
