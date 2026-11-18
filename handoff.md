# Handoff: "Traffic Shaffic" (Godot 4.7 2D puzzle game)

Everything a new Claude needs to continue this project. Read it top to bottom once, then use it as a reference.
Project folder: `c:\Users\Arjun\Desktop\traffic-shaffic-copy` (Windows, Git Bash and PowerShell). Godot 4.7.2.
Pronouns: the user's pronouns were never stated. Use they/them.

---

## 1. Where things stand (read first)

- **Branch:** `final-version` (tracks `origin/final-version`). Latest commit is `d626638 "fix bugs for level 2, level 3"`, made by the user. The working tree was clean after it. `origin/main-game` is at `0729ba4 "Added level 3"` (a teammate's commit). `final-version` was merged on top of it.
- **The user commits and pushes themselves.** Don't commit unless asked. Commits are meant for `final-version` only, not `main-game`. If you commit, end the message with the `Co-Authored-By` line the system reminder gives.
- **A stash still exists:** `stash@{0}: stash for level 2`. It holds the user's old pre-merge version of Level 2 and the old level flow, which main-game superseded. It is safe to `git stash drop` once the user agrees. Don't `pop` it, because it conflicts.
- **All 3 levels are playable and win/lose correctly** (tested headless, see section 9).
- **Not built yet:** the star rating / scoring (section 7), a level-select or progress screen, sound, and anything after Level 3. Victory in Level 3 hides the "next level" button.
- **Known leftovers and cleanup candidates** (nothing is broken because of them):
  - `scenes/game2.tscn` is a stale, committed leftover of the user's old Level 2. It references `res://scenes/level_2.tscn`, which no longer exists. Nothing uses it. Delete it with the user's OK.
  - Unused assets: `assets/npc.png`, `cattle ahead.png`, `civilian crossing ahead.png`, `school ahead.png`, `scripts/main.gd` (no scene or script references it by path), `Global.current_scene`. `20 kmph.png` is still in the speed sign's "20" animation inside `speed_limit.tscn`, but the 20 button was removed so that animation is never played. `scripts/npc2.gd` is a copy of `npc.gd` that one Level 1 pedestrian (`npc3`) uses.
  - **`project.godot` `run/main_scene` points at `object.tscn`** (uid `cvhmui15kk1yl`, the traffic signal scene). It came from the teammate's commit. F5 therefore runs only the traffic signal. Use F6 on `scenes/intro.tscn`, or point the main scene at `intro.tscn` (uid `be4fvif1bm1kf`). I told the user and offered; they haven't decided.
  - `res://icon.svg` is missing (harmless error in the log).
  - Level 2's bottom curb is cut off by the bottom of the screen because the road was moved down 100px (deliberate, see section 5).

---

## 2. The vision for the game

A small, educational, pixel-art **road-rules puzzle game set in India** (traffic law and signs follow Indian rules; the hover text is based on the Motor Vehicles Act 1988 and Indian mandatory-sign meanings).

How a level plays:
1. A car sits on a road with some traffic and obstacles. The player sees the road, an **ITEMS sidebar** on the right, and a play button in the top-left.
2. **Before pressing play** the player drags **signs / traffic items** from the sidebar onto the map (never on the road, always on the grass or the divider).
3. The player presses **play**. Nothing else is controlled. The car and the NPCs drive by themselves and **obey the signs the player placed**.
4. The level is won when the player's car reaches the **finish line**, which lights up green. There are three outcomes: win, "YOU CRASHED!", and "YOU DID NOT REACH HOME".

**The core idea (from the user): use as FEW signs as possible to get more stars.** Each level has an optimal ("par") solution (section 7). A level can be solved with more items, but fewer is better. The star system is not implemented yet.

Each level teaches different signs:
- Level 1: the **traffic signal** and pedestrians.
- Level 2: the **U-turn sign** (and a traffic signal as a distractor).
- Level 3: **speed limit** (a reckless driver), **compulsory right turn**, **stop sign**, plus decoys (**left turn**, **U-turn**, **traffic light**).

A recurring design rule from the user: **signs apply to ALL cars**, including the NPC cars, not just the player's car. A sign placed in front of the reckless NPC driver should stop or turn him.

---

## 3. The user's requests, in order (the story so far)

These are the prompts the user gave, grouped, so a new Claude understands the intent behind the code.

**Git and repo**
- Pull level 3 from `main-game` into `final-version` and only commit on `final-version`. Fix the merge conflicts.
- Tidy the repo: the `.godot/` cache was committed and `.gitignore` was a broken UTF-16 file. Both were fixed (`.godot/` untracked, `.vscode/`, `*.tmp` ignored).
- Rename levels so the user's own level became Level 2 and the pulled level became Level 3 (folders `scenes/Level1..3`, `scripts/Level2`, `scripts/Level3`).

**Visuals and layout**
- NPC sprites: use the new coloured pedestrian sprites. Each NPC has a fixed colour by order (orange, red, pink, yellow), never random. The back sprite shows while moving up the screen and the front sprite while moving down.
- Level 3 NPC cars: cyan and purple with their own 5-frame animations. The player's maroon car stays. The frames were re-aligned so all three cars sit centred on the lane.
- All hover/highlight info boxes are uniform across levels, with short Indian-law wording and positioned left of the item.
- Level 2: the road was moved down so it doesn't run under the play button. The U-turn sign's drawn "U-TURN" caption was removed. The U-turn icon flips and rotates 90° once picked up to match the road.
- Sidebars are uniform across levels (five evenly spaced slots, section 4).
- Stretch aspect changed from `expand` to `keep` (no empty space on the right in fullscreen).
- A checkered finish line that turns green when the player's car reaches it.

**Mechanics the user specified**
- **Signs cannot be on the road.** If dragged over the road they jump to the nearest grass. The WHOLE collision shape must clear the road, not just the centre.
- **Snap grid is 20px** in every level (it was 128 in Levels 1 and 3, 20 in Level 2).
- Dragging only moves ONE item at a time.
- **Traffic signal (Level 1 behaviour):** the car stops at a line before the signal, the light turns green, NPCs near it run off, the car continues. The NPC must be "near" the signal (safe zone). Needs "vicinity": if the signal is far from the car's lane it must not work.
- **U-turn sign (Level 2):** the car "sees" the sign with a ray. Correct place means it takes the U-turn. Wrong place means it turns there and crashes into the divider. The sign must also be in the vicinity of the car.
- **Level 3 redesign:** speed sign only toggles 30/50 and starts on 50. The reckless car behind drives at 50, the player and the car in front at 30. Toggling to 30 slows everyone to 30. The speed sign is **frozen once play is pressed**.
- Crash screen **at the instant** the 50 km/h car touches the player's car.
- Going straight in Level 3 (no turn): cars **don't crash and don't stop**, they drive off the screen, then a new **"YOU DID NOT REACH HOME"** screen shows.
- Stop sign and traffic light apply to **NPC cars** too. The stop sign became a draggable sidebar item. The traffic signal appears in all levels' sidebars and works on NPCs.
- Left-turn sign (decoy) and U-turn sign (Level 3): added, cars react (section 6).
- Level 2: the safe zone for the U-turn sign was widened and then narrowed back to 4 grid boxes (see section 5). The sign must never touch the road, including the visible median end caps and the gap.

**Working style of the user**
- Short, direct messages, sometimes with typos ("only f grid boxes" meant four). **If an instruction is genuinely ambiguous, ask one short question** (they answer quickly). Otherwise act.
- They test in the Godot editor. When they say "don't code anything yet", don't.
- They care about uniformity, not changing the art, and keeping things like "all signs apply to all cars" true everywhere.
- They want things verified. I verified every change headless (section 9) and by rendering screenshots.

---

## 4. How the game works (architecture)

### Folder layout
```
scenes/
  intro.tscn                menu (scripts/intro.gd): "new game" button -> Level 1
  Level1/level 1.tscn       Level 1
  Level2/level 2.tscn       Level 2 wrapper (signs, cow, sidebar, victory/death/not_home)
  Level2/map.tscn           Level 2 road map (two tile layers, intersections, car, play button, finish line)
  Level3/level 3.tscn       Level 3
  Level3/right_turn.tscn left_turn.tscn u_turn.tscn stop.tscn speed_limit.tscn
  car.tscn                  the player's car (script scripts/car.gd)
  npc_car.tscn              NPC cars, Level 3 (scripts/Level3/npc_car.gd)
  npc.tscn                  pedestrians (npc.gd / npc2.gd patrol, scripts/npc_sprite.gd picks colour)
  object.tscn               the TRAFFIC SIGNAL item (scripts/traffic_signal.gd)
  safezone.tscn             "near the NPCs" zones (group "safe")
  info_box.tscn             the shared hover box
  death.tscn victory.tscn not_home.tscn   end screens, all driven by scripts/scene_change.gd
scripts/
  global.gd                 autoload "Global": shared state + drag/road helpers
  car.gd                    player's car
  traffic_signal.gd         traffic signal item (Levels 1, 2, 3)
  finish_line.gd            finish line (Area2D, drawn in code)
  info_box.gd               hover box (top_level Label)
  scene_change.gd           death / victory / not_home screen logic + buttons
  npc.gd npc2.gd npc_sprite.gd intro.gd
  Level2/ level2.gd sign.gd (U-turn sign) cow.gd
  Level3/ level3.gd npc_car.gd right_turn.gd direction_sign.gd stop.gd speed_limit.gd speed_button.gd
assets/                     art; assets/npcs/ (8 pedestrian sprites), assets/cars/ (cyan/purple frames + .tres)
```

### `Global` autoload (`scripts/global.gd`)
- State: `safe` (signal is in an NPC safe zone), `play` (play pressed), `speed_mult` (player's car multiplier, used for stops), `speed_limit_kmh` (30 or 50, caps ALL cars), `next_level`, `drag_owner`, `extra_road_rects`.
- `speed_cap_px()`: 50 km/h = **200 px/s**, 30 km/h = **120 px/s**. Cars use `min(own speed, cap)`.
- `GRID = 20`.
- **Dragging helpers:** `mouse_over_area(area)` (exact point hit), `snap_drag()`, `area_footprint(item, area)` (item's whole collision shape), `footprint_on_road(centre, rect, round?)`, `is_road(point)`, `drag_position(mouse, grab_offset, rect, round?)` (snaps to the grid, and if any part would touch road, searches rings of grid points for the nearest clear spot).
- **What "road" means:** any tile on a `TileMapLayer` in the group `road_layer` (curbs included). In Level 2 both `Roads` and `RoadsVisual` are in the group (the visual layer has the median end caps and gap tiles). `extra_road_rects` adds areas that have no tile.
- **Reset on every level start** (and in the end-screen buttons): `play=false`, `safe=false`, `speed_mult=1`, `speed_limit_kmh=50`, `extra_road_rects` cleared (Level 2 sets its gap rect). Because the autoload outlives scene changes, forgetting a reset gave real bugs before.

### The play flow
- The level starts **paused** (`car.gd` calls `pause1()` in `_ready`). Pressing the top-left play button (`pause` Button, toggle mode) fires `car._on_pause_toggled`, which sets `Global.play = true` and unpauses.
- Items are all `process_mode = 3` (they still work while paused so you can drag before play) and refuse to drag once `Global.play` is true.
- Win, crash and not-home screens are nodes (`victory`, `death`, `not_home`) in each level. They start hidden and call `_on_car_death()` / `_on_car_victory()` from `scene_change.gd`, which shows them and pauses the tree. Buttons there unpause, reset globals and change scene.

### Items (drag-and-drop signs)
- Common pattern: a `Node2D` with an `Area2D` (the grabbable shape), a hidden `Label` (instance of `info_box.tscn`), and a `Ray` `Area2D` (collision_layer 0): a **tall thin box in front of the sign**. When a car's body overlaps the ray, the sign's effect fires. Ray box height gives the "vicinity" idea: if the sign is too far from the car's lane, the ray doesn't reach it.
- **Rules every item follows:**
  - Does nothing while it is still in the sidebar (`x >= 933`).
  - Ignores a car that is already past it (`car.x > sign.x`).
  - Each car obeys it at most once.
  - The trigger fires on any body with the right method, so the **player's car and the NPC cars both obey**.
- **Stop / traffic light stop duration:** 1.5 seconds total. The light holds red for 1.0s, then plays red to green, then the car goes about 0.5s later.
- **Sidebar slots:** the column is x=1038; slot y values are **180, 280, 380, 480, 580** in the same order everywhere (traffic light first).
- **Drag visuals:** hovering scales an item by 1.05. Right turn, left turn and U-turn rotate their picture 90° when picked up (the sidebar picture is the "upright" version).
- **Info box (`info_box.tscn`):** 230×190 teal box, font `PixelOperator8-Bold` 16px, always left of the item (right if no room), clamped on screen. Set per item with `title` and `description` on the `Label` node.

### Cars
- `scripts/car.gd` (player): follows the **direction tiles** of the road tilemap (custom data layer `direction`, values like `R`, `U`, `RU`). Probes ahead/behind to pick direction and the turn animation (`TURNS` table). `turn_sig = true` means "scripted motion, stop following tiles" (set by turn signs). Methods called by signs: `_on_turn_right_turn`, `_on_turn_left_turn`, `_on_u_turn` (Level 3), `stop_for(seconds)`. A crash is raised when its crash `Area2D` overlaps an NPC **or when its physics body touches an NPC** (`_check_hit_npc`).
- `scripts/Level3/npc_car.gd`: same movement; has `skin` ("cyan" or "purp", loads `assets/cars/<skin>_frames.tres`), `speed`, and the same sign methods plus `hit_player` signal (raised when its body touches the player's car, so a rear-end is a crash at the moment of contact).
- Speeds: car sprite frames are 320×320 at scale 0.5 (times 0.75 node scale). `U_TURN_SHIFT = 66` px (the U-turning car drops 66px, which is just over its body height, so it doesn't hit cars on the original line).

### Pedestrians
- `npc.tscn` has an `npc_sprite.gd` child that gives each pedestrian a fixed colour by order in the level and picks front/back from its movement. Level 1 pedestrians patrol y 200 to 350 (`npc.gd` constants). When a traffic signal switches near them (`traffic_switched` signal emitted every frame while `npcs_leaving`), they hop up and run off the road.

### Finish line (`scripts/finish_line.gd`)
- An `Area2D` with a `size` export. Checkered while waiting. When the **player's car** (group `maincar`) enters it and `Global.play` is true, it turns green (glow, pulsing), waits 0.5s, then finds the sibling node named `victory` (walks up the tree) and shows it.

---

## 5. Levels in detail

Coordinates are in game pixels (viewport 1152×648). The sidebar starts at x=933. Road centre lines are listed per level.

### Level 1: "learn the traffic signal"
- **Layout:** straight horizontal road, curbs y 200 to 225 (top) and 350 to 380 (bottom), asphalt about 225 to 350, lane/centre line y=285. The player's car starts at (56, 285) and drives right. Road tiles continue under the sidebar.
- **Actors:** 3 pedestrians crossing at x=793, 834, 878 (patrolling up/down). Two safe zones (StaticBody2D from `safezone.tscn`) at (755, 454) and (754, 207), scale (2, 4): about x 735 to 893 and y 414 to 494 / 167 to 247.
- **Mechanic:** the traffic signal item. If it sits on the grass and its collision shape overlaps a safe zone, `Global.safe` becomes true. The player's car stops at a line about 40px before the signal, the light goes green, the pedestrians run off, and the car drives on to the **finish line** at x=892 to 904, y=226 to 350.
- **Why it can still fail:** the signal must be near the NPCs. Away from them the pedestrians stay and the car hits one (crash). Because the signal can't touch the road and is about 72px tall, valid spots near a safe zone are about **y=140 to 160 (above) or y=420 to 500 (below), x about 740 to 780**.
- **Win condition:** reach the finish line.

### Level 2: "U-turn"
- **Layout:** two carriageways with a grey divider (median) between them and a **gap** in the divider. **The whole road is shifted down 100px** so the play button is on grass. Top lane asphalt about y 161 to 320, bottom lane about 480 to 640, divider band y 361 to 441. Tile layers `Map/Roads` (logic) and `Map/RoadsVisual`, both at position (-1, 101). The player's car starts at (81, 561) in the bottom lane heading right. A **cow** (pedestrian, `cow.gd`) stands at (880, 561) in that lane. The finish line is at x=56 to 68, y=162 to 320 (top lane, far left).
- **Mechanic (`level2.gd`):** the car "sees" the U-turn sign when its front (centre + 40) reaches the sign's x and the sign is within 220px of the car vertically.
  - **Sign centre inside `ZONES["u_turn"] = Rect2(320, 361, 80, 80)`:** `_open_route()` paints direction tiles through the gap into the top lane, the car takes the U-turn, drives left along the top lane and crosses the green finish line.
  - **Sign anywhere else:** the car turns up right there, hits the divider (`CRASH_Y = 475`), crash screen.
  - **No sign:** the car hits the cow, crash.
- **Where the sign can go:** it can't touch any road, including the median end caps (x about 400 to 437 and 600 to 640) and the gap itself (registered as `extra_road_rects` Rect2(437, 361, 163, 80)). The sign's circle is 56px and the divider band is 80px, so the only valid grid y is **400**, and the only valid x values touching the correct zone are **320, 340, 360**.
- **Traffic signal in Level 2:** it is a sidebar item too. A `SafeZone` at (691, 400) scale (2, 4) lies over the right half of the divider. A signal on the divider there (e.g. (760, 400)) makes the car stop, the cow run off (it moves down the screen), and the car drive on straight. Without the U-turn it then leaves the screen and shows **"did not reach home"**.
- **Win condition:** the player's car crosses the green finish line after the U-turn.

### Level 3: "reckless driver and the junction"
- **Layout:** one road with a **T-junction** to the right. Top curb y about 200 to 225, asphalt to about 350, centre line y=288. The side road runs down at x about 350 to 470 (the junction is roughly x 350 to 490). The finish line is at (352, 604), size 118×12, across the bottom of the side road.
- **Cars (evenly spaced 170px apart, all on y=288):**
  - purple (behind), x=56, `speed 200` (50 km/h): the **reckless driver**
  - player (maroon, middle), x=226, `speed 120` (30 km/h)
  - cyan (in front), x=396, `speed 120` (30 km/h)
- **The speed sign** (`speed_limit_30` node, at (302, 160) on the grass, not in the sidebar) starts on **50**. Click it before play to open 30/50 buttons. The limit caps every car. It is **frozen once play starts**.
  - **Left on 50:** the purple car catches up and rear-ends the player at about t=1.7s, so a crash.
  - **Set to 30:** everyone drives 120 px/s, so nobody catches anyone.
- **Sidebar items:** traffic light, right turn, left turn, U-turn, stop sign.
- **What each does to ALL cars that reach it** (ours and NPC):
  - **Right turn:** car turns right (south) at the sign. This is the intended solution.
  - **Left turn (decoy):** car turns north onto the grass, then a crash.
  - **U-turn (decoy):** car drops 66px and drives back west. When the player's car leaves the left edge (x<=-90) the **"did not reach home"** screen shows. If a head-on meeting happens (sign placed near the start, x about 420 to 460) it ends in a crash instead.
  - **Stop sign / traffic light:** car stops 1.5s, then drives on. A sign in front of the reckless driver stops only him (the others are already past it).
- **Outcomes** (`level3.gd`):
  - Win: crossing the finish line at the bottom of the side road.
  - Crash: turned too early or too late onto grass (off-road after turning), left turn, or any body contact between cars (the purple car rear-ending the player counts as soon as bodies touch).
  - "Did not reach home": the player never turned and drives off the right edge (x >= 1230, no crash, nothing stops), or the player U-turned and left on the left.
- **Right-turn sign position:** the car turns when its front touches a line about 49px before the sign, so the working window is the sign centre **x about 440 to 580**. It must be off the road, so **y <= 160 or y >= 420**. The ray reaches up to about 160px from the lane.

---

## 6. End screens
- `death.tscn`: "YOU CRASHED!" with *back to menu* and *restart level*.
- `victory.tscn`: "YOU DID IT!!!" with *next level*, *back to menu*, *restart level*. The *next level* button is hidden when `Global.next_level == ""` (Level 3 sets that).
- `not_home.tscn`: "YOU DID NOT REACH HOME" (2 lines, font 72) with the same two buttons. Used by Levels 2 and 3.
- All three use `scripts/scene_change.gd`. Level flow: intro -> Level 1 -> (victory "next") Level 2 -> Level 3 (`Global.next_level`).

---

## 7. Optimal solutions and the star idea

The user's concept: **fewer signs used = more stars.** Not implemented. Below is the "par" for each level (the minimum number of **sidebar items placed**), plus alternatives.

| Level | Optimal solution (par) | Items | Other valid solutions |
|---|---|---|---|
| 1 | Traffic signal on the grass beside the NPCs (overlapping a safe zone), e.g. (760, 140) or (760, 440) | **1** | none (the signal is the only item) |
| 2 | U-turn sign on the divider at (320, 400), (340, 400) or (360, 400) | **1** | none that win (the traffic signal only clears the cow and ends in "did not reach home") |
| 3 | Speed sign set to **30** (not an item, a free toggle) + **right turn** at x 440 to 580, y <= 160 or >= 420 | **1** | **2 items:** stop sign or traffic light in front of the purple car (e.g. stop at (200, 140), light at (200, 160)) + right turn, with the speed sign left on 50. All three speeds-and-signs combos win. |

Notes for implementing stars (proposal, not agreed):
- Count items placed outside the sidebar (an item still at x>=933 doesn't count). Decide whether the Level 3 speed toggle counts. My reading of the user's wording: it is not a sidebar item, so it is free.
- One idea: 3 stars at par, 2 stars at par+1, 1 star for any win. The user hasn't specified.
- Counting at play time: iterate the items that have been moved off the sidebar (`global_position.x < 933`).
- Decoy items (left turn, U-turn in Level 3; traffic signal in Level 2) exist so that fewer is not trivially "use nothing". Placing a wrong item can make the level fail.
- A good place to show stars: the victory screen.

---

## 8. Conventions and rules to keep true (don't regress these)
1. **Signs apply to all cars** (player + NPC cars). New signs must expose the same kind of method on cars and fire from a ray.
2. **Signs can never touch the road.** Use `Global.drag_position(...)` with the item's `area_footprint`. Tag any new level's road tilemap with group `road_layer`.
3. **Grid is 20px.** All items share the same sidebar column and slots.
4. **Unplaced items do nothing** (`x >= 933` guard), and a car already past a sign ignores it.
5. **Reset globals at level start.** If you add a new global that changes gameplay, reset it in every level's `_ready` and in `scene_change.gd`.
6. **The hover boxes are the shared `info_box.tscn`.** Don't draw per-item text boxes.
7. **Don't change the art** unless asked (the user was explicit about this).
8. Crash must fire at the moment of contact, and going off the road without turning in Level 3 must not crash or stop cars (it ends in "did not reach home" once the player's car is offscreen).
9. Pronouns: they/them.

---

## 9. Development environment, testing method and gotchas

- **Godot executable:** `C:\Users\Arjun\Downloads\Godot_v4.7.2-stable_win64_console.exe` (there is also a non-console `.exe`). No Python on the machine. Use bash/PowerShell/Godot only.
- **Run the project headless:** `godot --path . --headless --import --quit` (re-imports assets, prints parse errors; ignore the `icon.svg` error). Run one scene's logic with a custom script: `godot --path . --headless --fixed-fps 60 --script some_test.gd -- args`.
- **Test scripts (all disposable, they lived in the scratchpad and are gone):** a `SceneTree` script that `load()`s a level scene, `add_child`s it, waits a few frames, **moves item nodes with `global_position = ...`**, sets `lvl.get_node("pause").button_pressed = true` to press play, and then watches `lvl.get_node("death"/"victory"/"not_home").visible` and car positions for ~15 seconds. That is how every solution in section 7 was confirmed.
  - For Level 3 toggle the speed with `lvl.get_node("speed_limit_30")._on_thirty_pressed()`.
  - A test can also simulate real mouse drags with `Input.parse_input_event(...)`; **headless window coordinates are scaled**, so first convert positions with `root.get_final_transform() * p`.
- **Gotchas found the hard way:**
  - In a test `_initialize()`, `add_child(level)` does **not** run `_ready` immediately. Anything you set right after `add_child` can be overwritten by `_ready` (for example `Global.speed_limit_kmh`). Set test values a few frames later.
  - `Global` isn't resolvable as an identifier in a standalone `--script`; use `root.get_node("Global")`.
  - `--write-movie` (screenshots) renders at a fixed 10 fps and its physics tick is coarse, so **don't use it for gameplay timing**, only for visuals. Injected mouse events don't reach a windowed run.
  - **The Godot editor caches scripts.** If the user's editor was open while files changed on disk and they choose "ignore" or the editor is stale, the editor's game can differ from disk (it has caused errors like `invalid access to property drag_owner on global.gd`). Fix: File reload / close and reopen the project. Files on disk were correct each time.
  - When running Godot **from the CLI while the editor is open**, the editor's `.godot` cache can drift; if odd things happen, tell the user to restart Godot fully.
  - NPC cars and the player are `CharacterBody2D`s that **physically block each other**, so a rear-end is stopped at about 95px apart. Crash detection therefore uses body contact (`get_slide_collision`) in addition to the crash area.
  - Area2D `body_entered` can fire again when the tree unpauses, so every sign checks "is the car still before me?" (`car.x <= sign.x`) as well as `Global.play`.
  - `RoadsVisual` and `Roads` in Level 2 differ: only the visual layer has the median caps and gap tiles. Placement checks use both.
- **Where the numbers come from if you retune:** `SEE_AHEAD` (40), `SEE_HALF_HEIGHT` (220), `CRASH_Y`, `ZONES` in `scripts/Level2/level2.gd`; `U_TURN_SHIFT` in the car scripts; `STOP_SECONDS` in `scripts/Level3/stop.gd`; `NPC_STOP_SECONDS` in `traffic_signal.gd`; ray box sizes/positions in each item `.tscn` (`Ray/CollisionShape2D`); the speed cap in `Global.speed_cap_px()`; slot positions in each level `.tscn`.

---

## 10. Open questions / next steps for a new Claude
1. **Implement the stars** (section 7). Needs the user's rule for counting, UI on the victory screen, and per-level saved results if they want progress.
2. Decide the `main_scene` (currently `object.tscn`, should probably be `intro.tscn`).
3. Delete the stale `scenes/game2.tscn`, unused assets and `scripts/main.gd` / `npc2.gd` if the user agrees; drop `stash@{0}`.
4. More levels after Level 3 (there is no next level; the victory screen hides *next level*).
5. Possible polish the user may ask for: sound, a menu with level select, balancing the speeds, more decoys.
6. If the user reports "X stopped working" after an editor reload, first check whether the files on disk match and whether the editor cache is stale (section 9) before changing code. Then reproduce headless.
