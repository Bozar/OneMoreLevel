class_name Game_IntCoord


var x: int setget set_x, get_x
var y: int setget set_y, get_y


func _init(new_x: int, new_y: int) -> void:
	x = new_x
	y = new_y


func get_x() -> int:
	return x


func set_x(new_x) -> void:
	x = new_x


func get_y() -> int:
	return y


func set_y(new_y) -> void:
	y = new_y
