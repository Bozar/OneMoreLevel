const ObjectData := preload("res://scene/main/ObjectData.gd")
const SwitchSprite := preload("res://scene/main/SwitchSprite.gd")

var ref_ObjectData: ObjectData \
		setget set_ref_ObjectData, get_ref_ObjectData
var ref_SwitchSprite: SwitchSprite \
		setget set_ref_SwitchSprite, get_ref_SwitchSprite


func _init(object_data: ObjectData, switch_sprite: SwitchSprite) -> void:
	ref_ObjectData = object_data
	ref_SwitchSprite = switch_sprite


func get_ref_ObjectData() -> ObjectData:
	return ref_ObjectData


func set_ref_ObjectData(__: ObjectData) -> void:
	return


func get_ref_SwitchSprite() -> SwitchSprite:
	return ref_SwitchSprite


func set_ref_SwitchSprite(__: SwitchSprite) -> void:
	return
