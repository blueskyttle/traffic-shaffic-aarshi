extends Node2D
@onready var death: Node2D = $"."
@onready var victory: Node2D = $"."

func _ready() -> void:
	death.hide()
	victory.hide()

func _on_btm_pressed():
	get_tree().change_scene_to_file("res://scenes/intro.tscn")

func _on_restart_level_pressed():
	get_tree().reload_current_scene()

func _on_next_level_pressed():
	get_tree().change_scene_to_file("res://scenes/Level2/level 2.tscn")

func _on_car_death():
	death.show()
	get_tree().paused = true
	
func _on_car_victory() -> void:
	victory.show()
	get_tree().paused = true
