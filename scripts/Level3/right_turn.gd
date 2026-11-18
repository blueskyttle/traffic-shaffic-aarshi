extends Node2D
@onready var label: Label = $Label
@onready var rt_sprite: Sprite2D = $Sprite2D

signal right_turn
var is_dragging = false
var draggable = false #changes depending on if mouse is inside body or not
var offset: Vector2 #offset between global object position and mouse position

#on game start
func _ready():
	label.visible = false
	Global.play = false
	rt_sprite.rotation_degrees = 0
	
func _process(_delta):
	# Only one item can be dragged at a time (Global.drag_owner), and a drag can only
	# start when the click lands exactly on this item.
	if not is_instance_valid(Global.drag_owner):
		Global.drag_owner = null
	if Global.drag_owner == null:
		if Input.is_action_just_pressed("click") and not Global.play and Global.mouse_over_area($Area2D):
			Global.drag_owner = self
			offset = get_global_mouse_position() - global_position #calculates offset
			is_dragging = true
			label.visible = false
			rt_sprite.rotation_degrees = 90
	elif Global.drag_owner == self:
		if Input.is_action_pressed("click"):
			var fp := Global.area_footprint(self, $Area2D)
			global_position = Global.drag_position(get_global_mouse_position(), offset, fp[0], fp[1])
		else:
			_end_drag()

func _end_drag():
	Global.drag_owner = null
	is_dragging = false
	# The mouse may have left the item while dragging: refresh the hover state.
	if draggable and not Global.mouse_over_area($Area2D):
		draggable = false
		scale /= Vector2(1.05, 1.05)
		label.visible = false

func _exit_tree():
	if Global.drag_owner == self:
		Global.drag_owner = null


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


var turned: Array = []   # cars that already took the turn
const SIDEBAR_X := 933.0   # x where the sidebar starts

# Every car (ours and the NPC cars) obeys the sign: it turns right where the sign is.
func _on_area_2d_2_body_entered(body: Node2D):
	if global_position.x >= SIDEBAR_X:                # still in the sidebar, not placed: does nothing
		return
	# Cars that are already past the sign never "see" it.
	if not Global.play or body in turned or not body.has_method("_on_turn_right_turn"):
		return
	if body.global_position.x > global_position.x:
		return
	turned.append(body)
	body._on_turn_right_turn()
	if body.is_in_group('maincar'):
		right_turn.emit()

