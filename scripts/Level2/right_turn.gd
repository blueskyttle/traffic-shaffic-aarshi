extends Node2D
@onready var label: Label = $Label
@onready var rt_sprite: Sprite2D = $Sprite2D

signal right_turn
const tile_size = Vector2(128,128) #for snapping
var mouse_position: Vector2
var is_dragging = false
var draggable = false #changes depending on if mouse is inside body or not
var offset: Vector2 #offset between global object position and mouse position

#on game start
func _ready():
	label.visible = false
	Global.play = false
	rt_sprite.rotation_degrees = 0
	
func _process(delta):
	if draggable: #checks if mouse is in area body, prevents dragging from outside
		if Input.is_action_just_pressed("click"):
			offset = get_global_mouse_position() - global_position #calculates offset
			is_dragging = true
			rt_sprite.rotation_degrees = 90
		if Input.is_action_pressed("click"):
			mouse_position = get_global_mouse_position() - (tile_size/2 +offset) #applies offset and fixes snapping thoda
			global_position = mouse_position.snapped(tile_size) #actual position code
		elif Input.is_action_just_released("click"):
			is_dragging = false
			

func _on_area_2d_mouse_entered(): #connected to area2d in object, signals when mouse enters collision shape
	if not is_dragging and not Global.play: #for smooth movement
		scale *= Vector2(1.05,1.05)
		draggable = true
		label.visible = true
	if is_dragging:
		label.visible = false


func _on_area_2d_mouse_exited():
	if not is_dragging and not Global.play:
		scale /= Vector2(1.05,1.05)
		draggable = false
		label.visible = false


func _on_area_2d_2_body_entered(body: Node2D):
	if body.is_in_group('maincar'):
			right_turn.emit()
	
