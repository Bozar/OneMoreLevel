extends "res://library/pc_action/PCActionTemplate.gd"


const HALF_SIGHT_WIDTH: int = 1
const MEMORY_MARKER: int = 1
const SHOW_FULL_MAP: bool = false
# const SHOW_FULL_MAP: bool = true

var _new_RailgunData := preload("res://library/npc_data/RailgunData.gd").new()
var _new_LinearFOV := preload("res://library/LinearFOV.gd").new()

var _floor_wall_sprite: Array
var _counter_sprite: Array = []
var _kill_count: int = _new_RailgunData.MAX_KILL_COUNT
var _face_direction: Array = [0, -1]


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func set_target_position(direction: String) -> void:
	_face_direction = _direction_to_coord[direction]
	.set_target_position(direction)


func render_fov() -> void:
	_init_sprite()
	_render_counter(_kill_count)

	if SHOW_FULL_MAP:
		return

	_new_LinearFOV.set_rectangular_sight(
			_source_position[0], _source_position[1],
			_face_direction[0], _face_direction[1],
			_new_RailgunData.PC_FRONT_SIGHT, _new_RailgunData.PC_SIDE_SIGHT,
			HALF_SIGHT_WIDTH,
			self, "_is_obstacle", [])

	for i in _floor_wall_sprite:
		_set_color(i, _new_Palette.SHADOW, _new_Palette.DARK, true)


func _is_obstacle(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y)


func _init_sprite() -> void:
	var tmp_sprite: Array

	if _counter_sprite.size() == 0:
		for x in range(_new_DungeonSize.MAX_X - _new_RailgunData.COUNTER_WIDTH,
				_new_DungeonSize.MAX_X):
			_counter_sprite.push_back(_ref_DungeonBoard.get_sprite(
					_new_MainGroupTag.BUILDING,
					x, _new_DungeonSize.MAX_Y - 1))
			_counter_sprite.back().modulate = _new_Palette.DARK

	if SHOW_FULL_MAP:
		return

	if _floor_wall_sprite.size() == 0:
		_floor_wall_sprite = _ref_DungeonBoard.get_sprites_by_tag(
				_new_MainGroupTag.GROUND)
		tmp_sprite = _ref_DungeonBoard.get_sprites_by_tag(
				_new_SubGroupTag.WALL)
		_new_ArrayHelper.merge(_floor_wall_sprite, tmp_sprite)

		for i in _floor_wall_sprite:
			i.visible = false


func _set_color(set_this: Sprite, in_sight: String, out_of_sight: String,
		has_memory: bool) -> void:
	var pos: Array = _new_ConvertCoord.vector_to_array(set_this.position)

	if _new_LinearFOV.is_in_sight(pos[0], pos[1]):
		set_this.modulate = in_sight
		set_this.visible = true
		if has_memory and (_ref_ObjectData.get_hit_point(set_this) \
				< MEMORY_MARKER):
			_ref_ObjectData.set_hit_point(set_this, MEMORY_MARKER)
	elif has_memory and (_ref_ObjectData.get_hit_point(set_this) \
			== MEMORY_MARKER):
		set_this.modulate = out_of_sight
		set_this.visible = true


func _render_counter(kill: int) -> void:
	var counter: Array = []
	var sprite_type: String

	for _i in range(_new_RailgunData.COUNTER_WIDTH):
		if kill > _new_RailgunData.COUNTER_DIGIT:
			counter.push_front(_new_RailgunData.COUNTER_DIGIT)
		else:
			counter.push_front(kill)
		kill -= _new_RailgunData.COUNTER_DIGIT
		kill = max(kill, 0) as int

	for i in range(counter.size()):
		sprite_type = _new_SpriteTypeTag.convert_digit_to_tag(counter[i])
		_ref_SwitchSprite.switch_sprite(_counter_sprite[i], sprite_type)
