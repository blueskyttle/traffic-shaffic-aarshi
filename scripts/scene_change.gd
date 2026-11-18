extends Node2D
@onready var death: Node2D = $"."
@onready var victory: Node2D = $"."

func _ready() -> void:
	death.hide()
	victory.hide()

func _on_btm_pressed():
	get_tree().paused = false
	Global.play = false
	Global.safe = false
	Global.speed_mult = 1.0
	Global.speed_limit_kmh = 50.0
	get_tree().change_scene_to_file("res://scenes/intro.tscn")

func _on_restart_level_pressed():
	get_tree().paused = false
	Global.play = false
	Global.safe = false
	Global.speed_mult = 1.0
	Global.speed_limit_kmh = 50.0
	get_tree().reload_current_scene()

func _on_next_level_pressed():
	get_tree().paused = false
	Global.play = false
	Global.safe = false
	Global.speed_mult = 1.0
	Global.speed_limit_kmh = 50.0
	get_tree().change_scene_to_file(Global.next_level)

func _on_car_death():
	death.show()
	get_tree().paused = true
	
func _on_car_victory() -> void:
	# No further level: hide the "next level" button.
	if has_node("next level"):
		get_node("next level").visible = Global.next_level != ""
	victory.show()
	get_tree().paused = true
