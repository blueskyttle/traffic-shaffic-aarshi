extends Node2D

@onready var label: Label = $Label

func _ready():
	label.visible = false

func _on_area_2d_mouse_entered():
	label.visible = true

func _on_area_2d_mouse_exited():
	label.visible = false
