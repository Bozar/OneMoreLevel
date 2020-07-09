const ObjectData := preload("res://scene/main/ObjectData.gd")

var ref_ObjectData: ObjectData \
		setget set_ref_ObjectData, get_ref_ObjectData


func _init(object_data: ObjectData) -> void:
	ref_ObjectData = object_data


func get_ref_ObjectData() -> ObjectData:
	return ref_ObjectData


func set_ref_ObjectData(__: ObjectData) -> void:
	return
