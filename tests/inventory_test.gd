extends Node
## Automatic checks for the Backpack's inventory rules (inventory.gd) and
## the carrying rules (player/carry_limits.gd).
##
## HOW TO RUN: open tests/inventory_test.tscn and press F6.
## Look at the Output panel: every line should say PASS.
## If you ever change inventory.gd, run this again to make sure nothing broke.
## Vault: wiki/2 Building It/Code/tests/inventory_test.gd

var _passed := 0
var _failed := 0


func _ready() -> void:
	var walkie: ItemData = load("res://items/walkie_talkie.tres")   # 1x2
	var hammer: ItemData = load("res://items/hammer.tres")          # 2x2
	var crowbar: ItemData = load("res://items/crowbar.tres")        # 1x4
	var battery: ItemData = load("res://items/battery.tres")        # 1x1

	# --- Fitting rules ---
	var inv := Inventory.new()
	check("empty box: hammer fits top-left", inv.can_place_in_box(hammer.grid_size, Vector2i(0, 0)))
	check("can't stick out on the right", not inv.can_place_in_box(hammer.grid_size, Vector2i(5, 0)))
	check("can't stick out at the bottom", not inv.can_place_in_box(crowbar.grid_size, Vector2i(0, 1)))
	check("negative cell is outside", not inv.can_place_in_box(battery.grid_size, Vector2i(-1, 0)))

	# --- New items go to the belt first, then the box ---
	check("1st new item -> belt", inv.add_new(walkie) and inv.belt[0] == walkie)
	inv.add_new(walkie)
	inv.add_new(walkie)
	check("belt is now full", not inv.belt.has(null))
	check("4th new item -> box", inv.add_new(hammer) and inv.box.size() == 1)
	check("hammer placed at top-left", inv.box[0].cell == Vector2i(0, 0))
	check("overlap is refused", not inv.can_place_in_box(battery.grid_size, Vector2i(1, 1)))

	# --- A full box refuses more ---
	var full := Inventory.new()
	for slot in Inventory.BELT_SLOTS:   # fill the belt first, so hammers go in the box
		full.belt[slot] = battery
	for i in 6:                          # six 2x2 hammers fill a 6x4 grid exactly
		full.add_new(hammer)
	check("six hammers fill the box", full.box.size() == 6)
	check("7th hammer has no room", not full.add_new(hammer))

	# --- Moving and swapping ---
	var m := Inventory.new()
	m.add_new(walkie)                       # belt 1
	m.add_new(battery)                      # belt 2
	m.add_new(crowbar)                      # belt 3
	m.add_new(hammer)                       # box (0,0)
	check("move belt -> hands", m.move(Inventory.belt_location(0), Inventory.hands_location()) and m.hands == walkie and m.belt[0] == null)
	check("move hammer inside the box", m.move(Inventory.box_item_location(0), Inventory.box_cell_location(Vector2i(4, 2))) and m.box[0].cell == Vector2i(4, 2))
	check("move onto itself is fine", m.move(Inventory.box_item_location(0), Inventory.box_cell_location(Vector2i(4, 2))))
	check("swap belt <-> hands", m.move(Inventory.belt_location(1), Inventory.hands_location()) and m.hands == battery and m.belt[1] == walkie)
	check("crowbar can't swap in where it won't fit", not m.move(Inventory.box_item_location(0), Inventory.belt_location(2)))
	m.move(Inventory.box_item_location(0), Inventory.box_cell_location(Vector2i(0, 0)))   # hammer back to top-left
	check("swap box item with a belt item", m.move(Inventory.box_item_location(0), Inventory.belt_location(2)) and m.belt[2] == hammer and m.box[0].item == crowbar)

	# --- Picking up puts what you hold away first ---
	var p := Inventory.new()
	p.pick_up(walkie)
	check("pick up -> hands", p.hands == walkie)
	p.pick_up(hammer)
	check("pick up again: old item goes to belt", p.hands == hammer and p.belt[0] == walkie)

	# --- Dropping ---
	var dropped := p.drop(Inventory.hands_location())
	check("drop returns the item and empties hands", dropped == hammer and p.hands == null)
	check("has_item finds the walkie", p.has_item(walkie))

	# --- Carrying in your hands (Brandon, 10-15) ---
	# A made-up big artifact that needs both hands. ItemData.new() makes one in
	# code, just for this test, so we don't need a .tres file for it.
	var crate := ItemData.new()
	crate.display_name = "Test Crate"
	crate.grid_size = Vector2i(3, 3)
	crate.two_handed = true

	var c := Inventory.new()
	check("empty hands: can sprint", CarryLimits.can_sprint(c))
	check("empty hands: can use the wrist", CarryLimits.can_use_wrist(c))
	c.pick_up(battery)
	check("one-handed item: can still sprint", CarryLimits.can_sprint(c))
	check("one-handed item: can still use the wrist", CarryLimits.can_use_wrist(c))
	c.pick_up(crate)
	check("two-handed item: you're holding it with both hands", c.is_holding_two_handed())
	check("two-handed item: can't sprint", not CarryLimits.can_sprint(c))
	check("two-handed item: can't use the wrist", not CarryLimits.can_use_wrist(c))
	c.drop(Inventory.hands_location())
	check("dropped it: can sprint again", CarryLimits.can_sprint(c))

	# Backpack full? You can still carry something in your hands.
	check("full pack, empty hands: can still pick up", full.pick_up(crate) and full.hands == crate)
	check("full pack, hands full: can't pick up more", not full.pick_up(battery) and full.hands == crate)

	# --- Weight (Brandon, 10-15): heavier = slower + heavier breathing ---
	var light := ItemData.new()
	light.weight_kg = 2.0
	var heavy := ItemData.new()
	heavy.weight_kg = 20.0
	var w := Inventory.new()
	check("empty inventory weighs 0 kg", is_equal_approx(w.total_weight(), 0.0))
	w.add_new(light)                       # belt
	w.pick_up(heavy)                       # hands
	check("weight counts hands + belt", is_equal_approx(w.total_weight(), 22.0))
	for slot in Inventory.BELT_SLOTS:      # fill the belt so the next one goes in the box
		w.belt[slot] = light
	w.add_new(light)                       # box
	check("weight counts the box too", is_equal_approx(w.total_weight(), 28.0))

	# How loaded you are, from 0 (comfortable) to 1 (as heavy as it gets).
	# Here: up to 10 kg is comfortable, 40 kg is the most it can slow you.
	check("under 10 kg: not loaded at all", is_equal_approx(CarryLimits.load_fraction(6.0, 10.0, 40.0), 0.0))
	check("25 kg: half loaded", is_equal_approx(CarryLimits.load_fraction(25.0, 10.0, 40.0), 0.5))
	check("40 kg: fully loaded", is_equal_approx(CarryLimits.load_fraction(40.0, 10.0, 40.0), 1.0))
	check("over 40 kg: still just fully loaded", is_equal_approx(CarryLimits.load_fraction(90.0, 10.0, 40.0), 1.0))
	check("not loaded: normal speed", is_equal_approx(CarryLimits.speed_multiplier(0.0, 0.6), 1.0))
	check("half loaded: 80% speed", is_equal_approx(CarryLimits.speed_multiplier(0.5, 0.6), 0.8))
	check("fully loaded: slowest speed", is_equal_approx(CarryLimits.speed_multiplier(1.0, 0.6), 0.6))
	check("not loaded: normal breathing", is_equal_approx(CarryLimits.breath_multiplier(0.0, 1.5), 1.0))
	check("half loaded: breathe 1.25x as hard", is_equal_approx(CarryLimits.breath_multiplier(0.5, 1.5), 1.25))
	check("fully loaded: breathe 1.5x as hard", is_equal_approx(CarryLimits.breath_multiplier(1.0, 1.5), 1.5))

	print("---- Inventory tests: %d passed, %d failed ----" % [_passed, _failed])


func check(what: String, ok: bool) -> void:
	if ok:
		_passed += 1
		print("PASS  ", what)
	else:
		_failed += 1
		push_error("FAIL  " + what)
