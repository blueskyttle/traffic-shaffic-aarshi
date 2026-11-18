# The cow (a pedestrian) standing in the bottom lane of Level 2.
# When a traffic signal placed near it turns green, it runs off the road (down the screen),
# like the pedestrians in Level 1.
extends CharacterBody2D

const RUN_SPEED := 240.0
var leaving := false

func _on_traffic_signal_traffic_switched() -> void:
	leaving = true

func _process(delta: float) -> void:
	if leaving:
		position.y += RUN_SPEED * delta
