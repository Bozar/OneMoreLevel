extends Node2D
class_name Game_ReloadGame


const PATH_TO_MAIN := "res://scene/main/MainScene.tscn"


func reload() -> void:
	var new_scene: Node2D = load(PATH_TO_MAIN).instance()
	var old_scene: Node2D = get_tree().current_scene

	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

	get_tree().root.remove_child(old_scene)
	old_scene.queue_free()
