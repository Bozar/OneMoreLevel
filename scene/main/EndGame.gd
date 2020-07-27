extends Node2D


signal game_is_over(win)


func player_lose() -> void:
	emit_signal("game_is_over", false)


func player_win() -> void:
	emit_signal("game_is_over", true)
