extends Node2D
class_name Game_ObjectLayer
# When two sprites of the same main tag appears at the same position, put them
# into different layers. Refer to InitBaron.gd.


var _id_to_layer: Dictionary = {}


func get_layer(id: int) -> int:
	if not _id_to_layer.has(id):
		_id_to_layer[id] = 0
	return _id_to_layer[id]


func set_layer(id: int, layer: int) -> void:
	_id_to_layer[id] = layer


func remove_data(id: int) -> void:
	var __ = _id_to_layer.erase(id)
