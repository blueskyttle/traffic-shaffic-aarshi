# Sprite of a walking NPC (child of scenes/npc.tscn).
# Each NPC gets a fixed colour based on its order in the level (so it is the same
# every time, and different NPCs in one level get different colours). It shows the
# back of the character while it walks up the screen and the front while it walks down.
extends Sprite2D

# Colours are handed out in this order: 1st NPC -> orange, 2nd -> red, 3rd -> pink, 4th -> yellow.
const SKINS := [
	[preload("res://assets/npcs/orange_front.png"), preload("res://assets/npcs/orange_back.png")],
	[preload("res://assets/npcs/red_front.png"), preload("res://assets/npcs/red_back.png")],
	[preload("res://assets/npcs/pink_front.png"), preload("res://assets/npcs/pink_back.png")],
	[preload("res://assets/npcs/yellow_front.png"), preload("res://assets/npcs/yellow_back.png")],
]

var front: Texture2D
var back: Texture2D
var last_y: float

func _ready() -> void:
	add_to_group("npc_skin")
	last_y = get_parent().position.y
	_assign_skin.call_deferred()   # wait until every NPC of the level has registered

func _assign_skin() -> void:
	var rank := get_tree().get_nodes_in_group("npc_skin").find(self)
	var skin: Array = SKINS[maxi(rank, 0) % SKINS.size()]
	front = skin[0]
	back = skin[1]
	texture = front

func _process(_delta: float) -> void:
	if front == null:
		return
	var y: float = get_parent().position.y
	if y < last_y - 0.01:        # moving up the screen
		texture = back
	elif y > last_y + 0.01:      # moving down the screen
		texture = front
	last_y = y
