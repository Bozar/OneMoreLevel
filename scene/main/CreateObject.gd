extends Node2D
class_name Game_CreateObject


const ERR_MSG := "Duplicate sprite. MainTag: {0}, x: {1}, y: {2}, layer: {3}."

signal sprite_created(new_sprite, main_tag, sub_tag, x, y, sprite_layer)

var _ref_Palette: Game_Palette
var _ref_DungeonBoard: Game_DungeonBoard


func create_and_fetch_xy(prefab: PackedScene, main_tag: String, sub_tag: String,
		x: int, y: int, sprite_layer := 0,
		x_offset := 0, y_offset := 0) -> Sprite:
	var new_sprite: Sprite = prefab.instance() as Sprite
	var sprite_color: String = _ref_Palette.get_default_color(main_tag, sub_tag)
	var z_index: int = Game_ZIndex.get_z_index(main_tag)

	if _ref_DungeonBoard.has_sprite_xy(main_tag, x, y, sprite_layer):
		push_error(ERR_MSG.format([main_tag, String(x), String(y),
				String(sprite_layer)]))
		return null

	new_sprite.position = Game_ConvertCoord.coord_to_vector(x, y,
			x_offset, y_offset)
	new_sprite.add_to_group(main_tag)
	new_sprite.add_to_group(sub_tag)
	new_sprite.z_index = z_index
	new_sprite.modulate = sprite_color

	add_child(new_sprite)
	emit_signal("sprite_created", new_sprite, main_tag, sub_tag, x, y,
			sprite_layer)
	return new_sprite


func create_and_fetch(prefab: PackedScene, main_tag: String, sub_tag: String,
		coord: Game_IntCoord, sprite_layer := 0,
		x_offset := 0, y_offset := 0) -> Sprite:
	return create_and_fetch_xy(prefab, main_tag, sub_tag, coord.x, coord.y,
			sprite_layer, x_offset, y_offset)


func create_xy(prefab: PackedScene, main_tag: String, sub_tag: String,
		x: int, y: int, sprite_layer := 0,
		x_offset := 0, y_offset := 0) -> void:
	var __ = create_and_fetch_xy(prefab, main_tag, sub_tag, x, y, sprite_layer,
			x_offset, y_offset)


func create(prefab: PackedScene, main_tag: String, sub_tag: String,
		coord: Game_IntCoord, sprite_layer := 0,
		x_offset := 0, y_offset := 0) -> void:
	create_xy(prefab, main_tag, sub_tag, coord.x, coord.y, sprite_layer,
			x_offset, y_offset)


func create_ground_xy(prefab: PackedScene, sub_tag: String, x: int, y: int,
		sprite_layer := 0) -> void:
	create_xy(prefab, Game_MainTag.GROUND, sub_tag, x, y, sprite_layer)


func create_ground(prefab: PackedScene, sub_tag: String,
		coord: Game_IntCoord, sprite_layer := 0) -> void:
	create_ground_xy(prefab, sub_tag, coord.x, coord.y, sprite_layer)


func create_trap_xy(prefab: PackedScene, sub_tag: String, x: int, y: int,
		sprite_layer := 0) -> void:
	create_xy(prefab, Game_MainTag.TRAP, sub_tag, x, y, sprite_layer)


func create_trap(prefab: PackedScene, sub_tag: String,
		coord: Game_IntCoord, sprite_layer := 0) -> void:
	create_trap_xy(prefab, sub_tag, coord.x, coord.y, sprite_layer)


func create_building_xy(prefab: PackedScene, sub_tag: String, x: int, y: int,
		sprite_layer := 0) -> void:
	create_xy(prefab, Game_MainTag.BUILDING, sub_tag, x, y, sprite_layer)


func create_building(prefab: PackedScene, sub_tag: String,
		coord: Game_IntCoord, sprite_layer := 0) -> void:
	create_building_xy(prefab, sub_tag, coord.x, coord.y, sprite_layer)


func create_actor_xy(prefab: PackedScene, sub_tag: String, x: int, y: int,
		sprite_layer := 0) -> void:
	create_xy(prefab, Game_MainTag.ACTOR, sub_tag, x, y, sprite_layer)


func create_actor(prefab: PackedScene, sub_tag: String,
		coord: Game_IntCoord, sprite_layer := 0) -> void:
	create_actor_xy(prefab, sub_tag, coord.x, coord.y, sprite_layer)


func create_and_fetch_actor_xy(prefab: PackedScene, sub_tag: String,
		x: int, y: int, sprite_layer := 0) -> Sprite:
	return create_and_fetch_xy(prefab, Game_MainTag.ACTOR, sub_tag, x, y,
			sprite_layer)


func create_and_fetch_actor(prefab: PackedScene, sub_tag: String,
		coord: Game_IntCoord, sprite_layer := 0) -> Sprite:
	return create_and_fetch_actor_xy(prefab, sub_tag, coord.x, coord.y,
			sprite_layer)


func _on_SwitchScreen_screen_switched(_source: int, target: int) -> void:
	visible = (target == Game_ScreenTag.MAIN)
