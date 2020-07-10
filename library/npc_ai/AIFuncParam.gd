const ObjectData := preload("res://scene/main/ObjectData.gd")
const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")

var ref_ObjectData: ObjectData \
		setget set_ref_ObjectData, get_ref_ObjectData
var ref_DungeonBoard: DungeonBoard \
		setget set_ref_DungeonBoard, get_ref_DungeonBoard


func _init(object_data: ObjectData, dungeon_board: DungeonBoard) -> void:
	ref_ObjectData = object_data
	ref_DungeonBoard = dungeon_board


func get_ref_ObjectData() -> ObjectData:
	return ref_ObjectData


func set_ref_ObjectData(__: ObjectData) -> void:
	return


func get_ref_DungeonBoard() -> DungeonBoard:
	return ref_DungeonBoard


func set_ref_DungeonBoard(__: DungeonBoard) -> void:
	return
