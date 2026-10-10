extends Node
## Automatic checks for the Tool Box rules (inventory.gd).
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

	print("---- Inventory tests: %d passed, %d failed ----" % [_passed, _failed])


func check(what: String, ok: bool) -> void:
	if ok:
		_passed += 1
		print("PASS  ", what)
	else:
		_failed += 1
		push_error("FAIL  " + what)
