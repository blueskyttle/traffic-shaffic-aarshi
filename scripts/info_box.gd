# Shared "highlight box" shown when the mouse hovers an item (traffic signal, speed limit,
# stop sign, right turn, u-turn ...). The same scene is used in every level so the boxes
# look identical: same size, font and colour, whatever the scale of the item.
# The box sits to the left of the item (the item bar is on the right) and is kept on screen.
extends Label

@export var title: String = ""
@export_multiline var description: String = ""

const BOX_SIZE := Vector2(230, 190)   # on-screen size in pixels
const GAP := 44.0                     # distance between the item's centre and the box
const SCREEN := Vector2(1152, 648)
const MARGIN := 4.0

func _ready() -> void:
	top_level = true                   # ignore the item's scale / rotation
	z_index = 100
	custom_minimum_size = BOX_SIZE
	size = BOX_SIZE
	_refresh_text()

func _refresh_text() -> void:
	text = title if description == "" else title + "\n\n" + description

func set_info(new_title: String, new_description: String) -> void:
	title = new_title
	description = new_description
	_refresh_text()

func _process(_delta: float) -> void:
	if not visible:
		return
	var item := get_parent() as Node2D
	if item == null:
		return
	var p := item.global_position
	var x := p.x - GAP - size.x              # left of the item
	if x < MARGIN:                            # no room on the left: go to the right
		x = p.x + GAP
	x = clampf(x, MARGIN, SCREEN.x - size.x - MARGIN)
	var y := clampf(p.y - size.y / 2.0, MARGIN, SCREEN.y - size.y - MARGIN)
	global_position = Vector2(x, y)
