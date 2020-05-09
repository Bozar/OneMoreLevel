extends Node2D


signal sprite_removed(remove_sprite, main_group, x, y)

const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")

var _ref_DungeonBoard: DungeonBoard


func remove(main_group: String, x: int, y: int) -> void:
	var sprite: Sprite = _ref_DungeonBoard.get_sprite(main_group, x, y)

	emit_signal("sprite_removed", sprite, main_group, x, y)
	sprite.queue_free()
