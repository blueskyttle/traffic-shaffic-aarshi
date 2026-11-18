extends Node2D
@onready var label: Label = $Label
@onready var speed_sign: AnimatedSprite2D = $AnimatedSprite2D

signal clicked
signal unclicked
var inarea: bool = false

func _ready():
	label.visible = false
	inarea = false
	speed_sign.play("50")

func _process(delta):
	if Input.is_action_just_pressed("click") and inarea and not Global.play:
		label.visible = false
		clicked.emit()

func _on_area_2d_mouse_entered():
	label.visible = true
	inarea = true

func _on_area_2d_mouse_exited():
	label.visible = false
	inarea = false

func _on_twenty_pressed():
	Global.speed_mult = 0.4
	unclicked.emit()
	speed_sign.play("20")
	
func _on_thirty_pressed():
	Global.speed_mult = 0.6
	unclicked.emit()
	speed_sign.play("30")
	
func _on_fifty_pressed():
	Global.speed_mult = 1
	unclicked.emit()
	speed_sign.play("50")
