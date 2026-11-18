# Finish line of a level: a checkered strip across the road. When the player's car
# reaches it the strip lights up green and, a moment later, the victory screen shows.
extends Area2D

@export var size: Vector2 = Vector2(12, 120)   # width x height of the strip

const SQUARE := 6.0
const WHITE := Color(0.95, 0.95, 0.95)
const BLACK := Color(0.1, 0.1, 0.12)
const GREEN := Color(0.15, 0.9, 0.35)
const WIN_DELAY := 0.5

var reached := false
var time := 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1                  # sees the cars
	input_pickable = false
	var shape := RectangleShape2D.new()
	shape.size = size
	var cs := CollisionShape2D.new()
	cs.shape = shape
	cs.position = size / 2.0
	add_child(cs)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if reached:
		time += delta
		queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if reached or not Global.play or not body.is_in_group("maincar"):
		return
	reached = true                      # light up green
	queue_redraw()
	await get_tree().create_timer(WIN_DELAY).timeout
	var victory := _find_victory()
	if victory != null:
		victory._on_car_victory()

# The level's victory screen is a child named "victory" of the level root.
func _find_victory() -> Node:
	var n := get_parent()
	while n != null:
		if n.has_node("victory"):
			return n.get_node("victory")
		n = n.get_parent()
	return null

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	if reached:
		var pulse := 0.5 + 0.5 * sin(time * 8.0)
		draw_rect(rect.grow(8.0), Color(GREEN.r, GREEN.g, GREEN.b, 0.18 + 0.12 * pulse))   # glow
		draw_rect(rect.grow(3.0), Color(GREEN.r, GREEN.g, GREEN.b, 0.35))
		draw_rect(rect, GREEN)
		return
	var cols := ceili(size.x / SQUARE)
	var rows := ceili(size.y / SQUARE)
	for i in cols:
		for j in rows:
			var cell := Rect2(Vector2(i, j) * SQUARE, Vector2(SQUARE, SQUARE)).intersection(rect)
			draw_rect(cell, WHITE if (i + j) % 2 == 0 else BLACK)
