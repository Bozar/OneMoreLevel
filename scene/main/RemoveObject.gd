extends Node2D
class_name Game_RemoveObject


signal sprite_removed(remove_sprite, main_tag, x, y)

var _ref_DungeonBoard: Game_DungeonBoard


func remove(main_tag: String, x: int, y: int) -> void:
	var sprite: Sprite = _ref_DungeonBoard.get_sprite(main_tag, x, y)

	if sprite == null:
		return
	emit_signal("sprite_removed", sprite, main_tag, x, y)
	sprite.queue_free()


func remove_actor(x: int, y: int) -> void:
	remove(Game_MainTag.ACTOR, x, y)


func remove_building(x: int, y: int) -> void:
	remove(Game_MainTag.BUILDING, x, y)


func remove_trap(x: int, y: int) -> void:
	remove(Game_MainTag.TRAP, x, y)


func remove_ground(x: int, y: int) -> void:
	remove(Game_MainTag.GROUND, x, y)
