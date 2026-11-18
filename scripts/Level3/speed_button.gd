extends Button
@onready var button: Button = $"."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.visible = false


func _on_speed_limit_clicked():
	if Global.play:      # the speed is frozen once play is pressed
		return
	button.visible = true
	

func _on_speed_limit_unclicked():
	button.visible = false
