extends Node2D
class_name Game_RemoveObject


signal sprite_removed(remove_sprite, main_tag, x, y, sprite_layer)

var _ref_DungeonBoard: Game_DungeonBoard


func remove(main_tag: String, x: int, y: int, sprite_layer := 0) -> void:
	var remove_this: Sprite = _ref_DungeonBoard.get_sprite(main_tag, x, y,
			sprite_layer)
	if remove_this == null:
		return

	emit_signal("sprite_removed", remove_this, main_tag, x, y, sprite_layer)
	remove_this.queue_free()


func remove_actor(x: int, y: int, sprite_layer := 0) -> void:
	remove(Game_MainTag.ACTOR, x, y, sprite_layer)


func remove_building(x: int, y: int) -> void:
	remove(Game_MainTag.BUILDING, x, y)


func remove_trap(x: int, y: int) -> void:
	remove(Game_MainTag.TRAP, x, y)


func remove_ground(x: int, y: int) -> void:
	remove(Game_MainTag.GROUND, x, y)
