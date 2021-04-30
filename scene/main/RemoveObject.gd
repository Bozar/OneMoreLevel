extends Node2D
class_name Game_RemoveObject


signal sprite_removed(remove_sprite, main_group, x, y)

var _ref_DungeonBoard: Game_DungeonBoard


func remove(main_group: String, x: int, y: int) -> void:
	var sprite: Sprite = _ref_DungeonBoard.get_sprite(main_group, x, y)

	if sprite == null:
		return
	emit_signal("sprite_removed", sprite, main_group, x, y)
	sprite.queue_free()


func remove_actor(x: int, y: int) -> void:
	remove(Game_MainGroupTag.ACTOR, x, y)


func remove_building(x: int, y: int) -> void:
	remove(Game_MainGroupTag.BUILDING, x, y)


func remove_trap(x: int, y: int) -> void:
	remove(Game_MainGroupTag.TRAP, x, y)


func remove_ground(x: int, y: int) -> void:
	remove(Game_MainGroupTag.GROUND, x, y)
