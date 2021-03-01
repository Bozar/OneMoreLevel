extends "res://library/pc_action/PCActionTemplate.gd"


const HALF_SIGHT_WIDTH: int = 1
const MEMORY_MARKER: int = 1

var _new_RailgunData := preload("res://library/npc_data/RailgunData.gd").new()
var _new_LinearFOV := preload("res://library/LinearFOV.gd").new()

var _wall_sprite: Array
var _floor_sprite: Array
var _face_direction: Array = [0, -1]


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func set_target_position(direction: String) -> void:
	_face_direction = _direction_to_coord[direction]
	.set_target_position(direction)


func render_fov() -> void:
	_reset_sprite()

	_new_LinearFOV.set_rectangular_sight(
			_source_position[0], _source_position[1],
			_face_direction[0], _face_direction[1],
			_new_DungeonSize.MAX_X, _new_RailgunData.NPC_SIGHT,
			HALF_SIGHT_WIDTH,
			self, "_is_obstacle", [])

	for i in _wall_sprite:
		_set_color(i, _new_Palette.SHADOW, _new_Palette.DARK, true)
	for i in _floor_sprite:
		_set_color(i, _new_Palette.DARK, _new_Palette.DARK, true)


func _is_obstacle(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y)


func _reset_sprite() -> void:
	if _wall_sprite.size() == 0:
		_wall_sprite = _ref_DungeonBoard.get_sprites_by_tag(
				_new_SubGroupTag.WALL)
		for i in _wall_sprite:
			i.modulate = _new_Palette.BACKGROUND

	if _floor_sprite.size() == 0:
		_floor_sprite = _ref_DungeonBoard.get_sprites_by_tag(
				_new_MainGroupTag.GROUND)
		for i in _floor_sprite:
			i.modulate = _new_Palette.BACKGROUND


func _set_color(set_this: Sprite, in_sight: String, out_of_sight: String,
		has_memory: bool) -> void:
	var pos: Array = _new_ConvertCoord.vector_to_array(set_this.position)

	if _new_LinearFOV.is_in_sight(pos[0], pos[1]):
		set_this.modulate = in_sight
		if has_memory \
				and (_ref_ObjectData.get_hit_point(set_this) < MEMORY_MARKER):
			_ref_ObjectData.set_hit_point(set_this, MEMORY_MARKER)
	elif has_memory and \
		(_ref_ObjectData.get_hit_point(set_this) == MEMORY_MARKER):
		set_this.modulate = out_of_sight
