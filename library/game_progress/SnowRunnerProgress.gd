extends Game_ProgressTemplate


var _spr_Crystal := preload("res://sprite/Crystal.tscn")
var _spr_DoorTruck := preload("res://sprite/DoorTruck.tscn")
var _spr_OffloadGoods := preload("res://sprite/OffloadGoods.tscn")

var _is_first_turn := true
var _fake_door_coords := []
var _ground_coords := []


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func start_first_turn(_pc_coord: Game_IntCoord) -> void:
	_replenish_snow()


func end_world(_pc_coord: Game_IntCoord) -> void:
	# print(_ground_coords.size())
	_melt_snow()
	_replenish_snow()
	_update_doors()
	_init_offload_goods()
	_replenish_offload()


func create_ground(_ground: Sprite, _sub_tag: String, x: int, y: int) -> void:
	_ground_coords.push_back(Game_IntCoord.new(x, y))


func _melt_snow() -> void:
	var hp: int
	var pos: Game_IntCoord

	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.SNOW):
		match _ref_ObjectData.get_hit_point(i):
			Game_SnowRunnerData.NO_SNOW:
				hp = _ref_RandomNumber.get_int(1, Game_SnowRunnerData.SNOW_FALL)
				_ref_ObjectData.add_hit_point(i, hp)
			Game_SnowRunnerData.SNOW_MELT:
				pos = Game_ConvertCoord.sprite_to_coord(i)
				_ref_RemoveObject.remove_trap(pos)
			_:
				_ref_ObjectData.add_hit_point(i, 1)


func _replenish_snow() -> void:
	var snow := _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.SNOW).size()

	Game_WorldGenerator.create_by_coord(_ground_coords,
			Game_SnowRunnerData.MAX_SNOW - snow, _ref_RandomNumber, self,
			"_is_valid_snow_coord", [],
			"_create_snow_here", [])


func _update_doors() -> void:
	var hp: int
	var doors := _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.DOOR)

	for i in doors:
		match _ref_ObjectData.get_hit_point(i):
			Game_SnowRunnerData.NO_PASSENGER:
				hp = _ref_RandomNumber.get_int(1,
						Game_SnowRunnerData.PASSENGER_WAIT)
				_ref_ObjectData.add_hit_point(i, hp)
			Game_SnowRunnerData.PASSENGER_ARRIVE:
				_ref_ObjectData.add_hit_point(i, 1)
				_ref_ObjectData.set_state(i, Game_StateTag.ACTIVE)
				_ref_SwitchSprite.set_sprite(i, Game_SpriteTypeTag.ACTIVE)
			Game_SnowRunnerData.PASSENGER_LEAVE:
				hp = Game_SnowRunnerData.NO_PASSENGER
				_ref_ObjectData.set_hit_point(i, hp)
				_ref_ObjectData.set_state(i, Game_StateTag.DEFAULT)
				_ref_SwitchSprite.set_sprite(i, Game_SpriteTypeTag.DEFAULT)
			_:
				_ref_ObjectData.add_hit_point(i, 1)


func _init_offload_goods() -> void:
	if not _is_first_turn:
		return

	var offloads := _ref_DungeonBoard.get_sprites_by_tag(
			Game_SubTag.OFFLOAD_GOODS)
	var pos: Game_IntCoord
	var new_sprite: PackedScene
	var new_sub_tag: String

	Game_ArrayHelper.shuffle(offloads, _ref_RandomNumber)
	for i in range(0, offloads.size()):
		pos = Game_ConvertCoord.sprite_to_coord(offloads[i])
		_ref_RemoveObject.remove_building(pos)
		if i < Game_SnowRunnerData.MAX_OFFLOAD:
			new_sprite = _spr_OffloadGoods
			new_sub_tag = Game_SubTag.OFFLOAD_GOODS
		else:
			_fake_door_coords.push_back(pos)
			new_sprite = _spr_DoorTruck
			new_sub_tag = Game_SubTag.DOOR
		_ref_CreateObject.create_building(new_sprite, new_sub_tag, pos)
	_is_first_turn = false


func _replenish_offload() -> void:
	var offload := _ref_DungeonBoard.get_sprites_by_tag(
			Game_SubTag.OFFLOAD_GOODS).size()
	var fake_door := _fake_door_coords.size()
	var pos: Game_IntCoord

	if (offload < Game_SnowRunnerData.MAX_OFFLOAD) and (fake_door > 0):
		pos = _fake_door_coords.pop_back()
		_ref_RemoveObject.remove_building(pos)
		_ref_CreateObject.create_building(_spr_OffloadGoods,
				Game_SubTag.OFFLOAD_GOODS, pos)


func _is_valid_snow_coord(coord: Game_IntCoord, retry: int, _arg: Array) \
		-> bool:
	var count_snow := 0

	if _ref_DungeonBoard.has_trap(coord) or _ref_DungeonBoard.has_actor(coord):
		return false
	elif retry < 1:
		for i in Game_CoordCalculator.get_neighbor(coord, 1):
			if _ref_DungeonBoard.has_trap(i):
				count_snow += 1
				if count_snow > 1:
					return false
	return true


func _create_snow_here(coord: Game_IntCoord,  _arg: Array) -> void:
	_ref_CreateObject.create_trap(_spr_Crystal, Game_SubTag.SNOW, coord)
