extends Button
@onready var button: Button = $"."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.visible = false


func _on_speed_limit_clicked():
	button.visible = true
	

func _on_speed_limit_unclicked():
	button.visible = false
