extends Node2D




func _ready() -> void:
	# Safety net: never arrive at the menu with the game still paused.
	get_tree().paused = false

func _on_button_pressed():
	Global.next_level = "res://scenes/Level2/level 2.tscn"
	get_tree().change_scene_to_file("res://scenes/Level1/level 1.tscn")
