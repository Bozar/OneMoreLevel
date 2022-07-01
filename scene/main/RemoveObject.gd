extends Node2D
class_name Game_RemoveObject


signal sprite_removed(remove_sprite, main_tag, x, y, sprite_layer)

var _ref_DungeonBoard: Game_DungeonBoard


func remove_xy(main_tag: String, x: int, y: int, sprite_layer := 0) -> void:
	var remove_this: Sprite = _ref_DungeonBoard.get_sprite_xy(main_tag, x, y,
			sprite_layer)
	if remove_this == null:
		return

	emit_signal("sprite_removed", remove_this, main_tag, x, y, sprite_layer)
	remove_this.queue_free()


func remove(main_tag: String, coord: Game_IntCoord, sprite_layer := 0) -> void:
	remove_xy(main_tag, coord.x, coord.y, sprite_layer)


func remove_actor_xy(x: int, y: int, sprite_layer := 0) -> void:
	remove_xy(Game_MainTag.ACTOR, x, y, sprite_layer)


func remove_actor(coord: Game_IntCoord, sprite_layer := 0) -> void:
	remove_actor_xy(coord.x, coord.y, sprite_layer)


func remove_building_xy(x: int, y: int) -> void:
	remove_xy(Game_MainTag.BUILDING, x, y)


func remove_building(coord: Game_IntCoord) -> void:
	remove_building_xy(coord.x, coord.y)


func remove_trap_xy(x: int, y: int) -> void:
	remove_xy(Game_MainTag.TRAP, x, y)


func remove_trap(coord: Game_IntCoord) -> void:
	remove_trap_xy(coord.x, coord.y)


func remove_ground_xy(x: int, y: int) -> void:
	remove_xy(Game_MainTag.GROUND, x, y)


func remove_ground(coord: Game_IntCoord) -> void:
	remove_ground_xy(coord.x, coord.y)
