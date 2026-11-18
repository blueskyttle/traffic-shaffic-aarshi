extends CharacterBody2D

const SPEED = 100.0
var direction = 1
var tm

func _process(delta):
	tm = delta
	position.y += direction * SPEED * delta
	if position.y < 200:
		direction = 1
	if position.y > 350:
		direction = -1


func _on_traffic_signal_traffic_switched() -> void:
	await get_tree().create_timer(0.6).timeout
	position.y += SPEED * tm * -3.5
