extends Node2D
class_name Game_EndGame


signal game_over(win)


func player_lose() -> void:
	emit_signal("game_over", false)


func player_win() -> void:
	emit_signal("game_over", true)
