# Level 3: the car has to take the side road at the compulsory-right-turn sign.
# - Reaching the finish line at the bottom of the side road wins the level (finish_line.gd).
# - A U-turn sends the cars back the way they came: they leave on the left and the same
#   "did not reach home" screen shows once the player's car is gone.
# - Driving straight on (never turning): nothing crashes and nothing stops, the cars just
#   drive off the right edge of the screen. Once the player's car is gone the "you did not
#   reach home" screen shows.
# - Any other failure (turning too early or too late onto the grass, being hit by another
#   car, ...) is a crash.
extends Node2D

const MISSED_TURN_X := 490.0   # the side road is to the left of this x; beyond it the turn is missed
const OFFSCREEN_X := 1230.0    # the player's car is completely off the right edge of the screen
const LEFT_OFFSCREEN_X := -90.0  # the player's car has U-turned and left the screen on the left

@onready var roads: TileMapLayer = $Roads
@onready var car: CharacterBody2D = $car
@onready var death: Node2D = $death
@onready var not_home: Node2D = $not_home

var finished := false

func _ready() -> void:
	Global.speed_mult = 1.0
	Global.speed_limit_kmh = 50.0
	Global.extra_road_rects.clear()
	# Last level for now: the victory screen hides its "next level" button.
	Global.next_level = ""
	# Every failure goes through _fail so the right screen is chosen.
	car.death.connect(_fail)
	for npc in get_tree().get_nodes_in_group("npc"):
		if npc.has_signal("hit_player"):
			npc.hit_player.connect(_fail)

func _physics_process(_delta: float) -> void:
	if finished or not Global.play:
		return
	if car.u_turned:
		# U-turned: nothing crashes, the car drives back off the left edge of the screen.
		if car.global_position.x <= LEFT_OFFSCREEN_X:
			finished = true
			not_home._on_car_death()
		return
	if not car.turn_sig:
		# Straight on: no crash at the end of the road, the car just keeps driving.
		if car.global_position.x >= OFFSCREEN_X:
			_fail()
		return
	# Turned, but off the road (too early or too late): it is on the grass.
	var on_road := roads.get_cell_tile_data(roads.local_to_map(roads.to_local(car.global_position))) != null
	if not on_road:
		_fail()

func _fail() -> void:
	if finished:
		return
	finished = true
	if not car.turn_sig and car.global_position.x > MISSED_TURN_X:
		not_home._on_car_death()     # drove on past the junction: did not reach home
	else:
		death._on_car_death()        # crashed
