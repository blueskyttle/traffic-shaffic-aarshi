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
	var stars := Global.stars_for(Global.items_used())
	Global.complete_level(get_tree().current_scene.scene_file_path, stars)
	_show_stars(stars)
	# No further level: hide the "next level" button.
	if has_node("next level"):
		get_node("next level").visible = Global.next_level != ""
	victory.show()
	get_tree().paused = true

# Victory screen: three stars between the heading and the buttons, gold for the ones earned.
func _show_stars(earned: int) -> void:
	var gold: Texture2D = load("res://assets/gold star.png")
	var gray: Texture2D = load("res://assets/gray star.png")
	for i in 3:
		var s := Sprite2D.new()
		s.texture = gold if i < earned else gray
		s.scale = Vector2(0.2, 0.2)
		s.position = Vector2((i - 1) * 80, 0)
		add_child(s)
