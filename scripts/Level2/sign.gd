# Draggable traffic sign used in level 2 (one-way sign / u-turn sign).
# The sign lives in the sidebar; drag it onto the map and it snaps to the grid.
# The level script (level2.gd) decides whether it was placed correctly.
extends Node2D

@export_enum("one_way", "u_turn") var kind: String = "one_way"
@export var title: String = "SIGN"
@export_multiline var info: String = ""

const GRID := 20
const RADIUS := 28.0
const SIDEBAR_X := 933.0
const BLUE := Color(0.05, 0.27, 0.65)
const UTURN_TEX := preload("res://assets/u-turn.png")
const FONT := preload("res://assets/PixelOperator8-Bold.ttf")
const INFO_BOX := preload("res://scenes/info_box.tscn")   # same highlight box as the other items

var home: Vector2
var dragging := false
var hovered := false
var grab_offset := Vector2.ZERO
var info_box: Label

signal moved

func _ready() -> void:
	home = position
	info_box = INFO_BOX.instantiate()
	info_box.visible = false
	add_child(info_box)
	info_box.set_info(title, info)
	z_index = 10

func is_in_sidebar() -> bool:
	return position.x >= SIDEBAR_X

func _hit(p: Vector2) -> bool:
	return p.distance_to(global_position) <= RADIUS * 1.1

func _update_info_box() -> void:
	info_box.visible = hovered and not dragging and not Global.play and info != ""

func _process(_delta: float) -> void:
	if Global.play:
		if hovered or dragging:
			hovered = false
			dragging = false
			queue_redraw()
		_update_info_box()
		return
	var h := _hit(get_global_mouse_position()) and not dragging
	if h != hovered:
		hovered = h
		scale = Vector2.ONE * (1.08 if hovered else 1.0)
		queue_redraw()
	if dragging:
		var m := get_global_mouse_position() - grab_offset
		position = Global.drag_position(get_global_mouse_position(), grab_offset, Rect2(-RADIUS, -RADIUS, RADIUS * 2, RADIUS * 2), true)
	_update_info_box()

func _input(event: InputEvent) -> void:
	if Global.play or not (event is InputEventMouseButton) or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		if _hit(get_global_mouse_position()):
			dragging = true
			grab_offset = get_global_mouse_position() - global_position
			scale = Vector2.ONE * 1.08
			queue_redraw()
			get_viewport().set_input_as_handled()
	elif dragging:
		dragging = false
		position.x = clampf(position.x, GRID * 2, 1140.0)
		position.y = clampf(position.y, GRID * 2, 630.0)
		# Dropped back onto the sidebar -> return to the rack.
		if position.x >= SIDEBAR_X - RADIUS:
			position = home
		queue_redraw()
		moved.emit()

func _draw() -> void:
	if kind == "u_turn":
		_draw_u_turn()
	else:
		_draw_one_way()

func _draw_u_turn() -> void:
	var rect := Rect2(-RADIUS, -RADIUS, RADIUS * 2, RADIUS * 2)
	if dragging or not is_in_sidebar():
		# On the road the car drives right, up the gap and back left, so flip the
		# sidebar icon and turn it 90 degrees (like the right-turn sign when dragged).
		draw_set_transform(Vector2.ZERO, PI / 2.0, Vector2(-1, 1))
		draw_texture_rect(UTURN_TEX, rect, false)
		draw_set_transform_matrix(Transform2D.IDENTITY)
	else:
		draw_texture_rect(UTURN_TEX, rect, false)

func _draw_one_way() -> void:
	var r := Rect2(-RADIUS, -RADIUS * 0.62, RADIUS * 2, RADIUS * 1.24)
	draw_rect(r, Color.WHITE)
	draw_rect(r.grow(-3), BLUE)
	draw_line(Vector2(-19, 0), Vector2(8, 0), Color.WHITE, 6.0)
	draw_colored_polygon(PackedVector2Array([Vector2(5, -12), Vector2(21, 0), Vector2(5, 12)]), Color.WHITE)
