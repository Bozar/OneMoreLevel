extends Game_ProgressTemplate


var _spr_Crystal := preload("res://sprite/Crystal.tscn")

var _is_first_turn := true
var _snowfall := Game_SnowRunnerData.SNOWFALL
var _door_sprites: Array
var _ground_coords: Array


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func renew_world(_pc_x: int, _pc_y: int) -> void:
	_init_doors()


func end_world(_pc_x: int, _pc_y: int) -> void:
	_replenish_snow()
	_update_doors()


func create_building(building: Sprite, sub_tag: String, _x: int, _y: int) \
		-> void:
	if sub_tag == Game_SubTag.DOOR:
		_door_sprites.push_back(building)


func create_ground(_ground: Sprite, _sub_tag: String, x: int, y: int) -> void:
	_ground_coords.push_back(Game_IntCoord.new(x, y))


func remove_trap(_trap: Sprite, _x: int, _y: int) -> void:
	_snowfall -= 1


func _init_doors() -> void:
	if not _is_first_turn:
		return

	var this_door: Sprite

	_is_first_turn = false
	Game_ArrayHelper.shuffle(_door_sprites, _ref_RandomNumber)

	for i in range(0, Game_SnowRunnerData.INITIAL_PASSENGER):
		this_door = _door_sprites[i]
		_ref_ObjectData.set_state(this_door, Game_StateTag.ACTIVE)
		_ref_SwitchSprite.set_sprite(this_door, Game_SpriteTypeTag.ACTIVE)
		_ref_ObjectData.set_hit_point(this_door,
				Game_SnowRunnerData.PASSENGER_ARRIVE)


func _replenish_snow() -> void:
	var this_index: int
	var this_coord: Game_IntCoord

	while _snowfall < Game_SnowRunnerData.SNOWFALL:
		this_index = _ref_RandomNumber.get_int(0, _ground_coords.size())
		this_coord = _ground_coords[this_index]
		if _ref_DungeonBoard.has_trap(this_coord.x, this_coord.y) \
				or _ref_DungeonBoard.has_actor(this_coord.x, this_coord.y):
			continue
		_ref_CreateObject.create_trap(_spr_Crystal, Game_SubTag.SNOW,
				this_coord.x, this_coord.y)
		_snowfall += 1


func _update_doors() -> void:
	var hp: int

	for i in _door_sprites:
		match _ref_ObjectData.get_hit_point(i):
			Game_SnowRunnerData.NO_PASSENGER:
				hp = _ref_RandomNumber.get_int(Game_SnowRunnerData.NO_PASSENGER,
						Game_SnowRunnerData.PASSENGER_WAIT)
				_ref_ObjectData.set_hit_point(i, hp)
			Game_SnowRunnerData.PASSENGER_ARRIVE:
				_ref_ObjectData.set_state(i, Game_StateTag.ACTIVE)
				_ref_SwitchSprite.set_sprite(i, Game_SpriteTypeTag.ACTIVE)
				_ref_ObjectData.add_hit_point(i, 1)
			Game_SnowRunnerData.PASSENGER_LEAVE:
				hp = Game_SnowRunnerData.NO_PASSENGER
				_ref_ObjectData.set_state(i, Game_StateTag.DEFAULT)
				_ref_SwitchSprite.set_sprite(i, Game_SpriteTypeTag.DEFAULT)
				_ref_ObjectData.set_hit_point(i, hp)
			_:
				_ref_ObjectData.add_hit_point(i, 1)
