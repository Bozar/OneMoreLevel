extends Node2D
class_name Game_CreateObject


signal sprite_created(new_sprite, main_tag, sub_tag, x, y, layer)

var _ref_Palette: Game_Palette


func create_and_fetch(prefab: PackedScene, main_tag: String, sub_tag: String,
		x: int, y: int, layer := 0,
		x_offset := 0, y_offset := 0) -> Sprite:
	var new_sprite: Sprite = prefab.instance() as Sprite
	var sprite_color: String = _ref_Palette.get_default_color(main_tag, sub_tag)
	var z_index: int = Game_ZIndex.get_z_index(main_tag)

	new_sprite.position = Game_ConvertCoord.coord_to_vector(x, y,
			x_offset, y_offset)
	new_sprite.add_to_group(main_tag)
	new_sprite.add_to_group(sub_tag)
	new_sprite.z_index = z_index
	new_sprite.modulate = sprite_color

	add_child(new_sprite)
	emit_signal("sprite_created", new_sprite, main_tag, sub_tag, x, y, layer)
	return new_sprite


func create(prefab: PackedScene, main_tag: String, sub_tag: String,
		x: int, y: int, layer := 0,
		x_offset := 0, y_offset := 0) -> void:
	var __ = create_and_fetch(prefab, main_tag, sub_tag, x, y, layer,
			x_offset, y_offset)


func create_ground(prefab: PackedScene, sub_tag: String, x: int, y: int,
		layer := 0) -> void:
	create(prefab, Game_MainTag.GROUND, sub_tag, x, y, layer)


func create_trap(prefab: PackedScene, sub_tag: String, x: int, y: int,
		layer := 0) -> void:
	create(prefab, Game_MainTag.TRAP, sub_tag, x, y, layer)


func create_building(prefab: PackedScene, sub_tag: String, x: int, y: int,
		layer := 0) -> void:
	create(prefab, Game_MainTag.BUILDING, sub_tag, x, y, layer)


func create_actor(prefab: PackedScene, sub_tag: String, x: int, y: int,
		layer := 0) -> void:
	create(prefab, Game_MainTag.ACTOR, sub_tag, x, y, layer)


func create_and_fetch_ground(prefab: PackedScene, sub_tag: String,
		x: int, y: int, layer := 0) -> Sprite:
	return create_and_fetch(prefab, Game_MainTag.GROUND, sub_tag, x, y, layer)


func create_and_fetch_trap(prefab: PackedScene, sub_tag: String, x: int, y: int,
		layer := 0) -> Sprite:
	return create_and_fetch(prefab, Game_MainTag.TRAP, sub_tag, x, y, layer)


func create_and_fetch_building(prefab: PackedScene, sub_tag: String,
		x: int, y: int, layer := 0) -> Sprite:
	return create_and_fetch(prefab, Game_MainTag.BUILDING, sub_tag, x, y, layer)


func create_and_fetch_actor(prefab: PackedScene, sub_tag: String,
		x: int, y: int, layer := 0) -> Sprite:
	return create_and_fetch(prefab, Game_MainTag.ACTOR, sub_tag, x, y, layer)


func _on_SwitchScreen_screen_switched(screen_tag: int) -> void:
	visible = (screen_tag == Game_ScreenTag.MAIN)
