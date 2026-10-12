extends Node
## Automatic checks for the Clean Air rules (clean_air.gd).
##
## HOW TO RUN: open tests/clean_air_test.tscn and press F6.
## Look at the Output panel: every line should say PASS.
## If you ever change clean_air.gd, run this again to make sure nothing broke.
## Vault: wiki/2 Building It/Code/tests/clean_air_test.gd

var _passed := 0
var _failed := 0
var _ran_out_count := 0   # how many times the "ran_out" signal fired


func _ready() -> void:
	# --- A new tank starts full ---
	var air := CleanAir.new(480.0)   # 480 seconds = 8 minutes
	check("new tank is full", is_equal_approx(air.seconds_left, 480.0))
	check("full tank = 100%", is_equal_approx(air.get_percent(), 1.0))
	check("full tank is not empty", not air.is_empty())

	# --- Breathing drains it, one second per second ---
	air.breathe(60.0)   # one minute passes
	check("1 minute of breathing leaves 7 minutes", is_equal_approx(air.seconds_left, 420.0))

	# --- A FAST computer takes thousands of tiny breaths: they must still add up ---
	# (Bug found 2026-10-11: on Brandon's PC, ~0.001 s frames were ignored.)
	var fast := CleanAir.new(480.0)
	for i in 1000:
		fast.breathe(0.001)   # 1000 frames of 0.001 s = 1 second
	check("1000 tiny breaths drain 1 second", is_equal_approx(fast.seconds_left, 479.0))
	for i in 1000:
		fast.refill(0.001)
	check("1000 tiny refills add 1 second", is_equal_approx(fast.seconds_left, 480.0))

	# --- It can't go below zero, and "ran_out" fires only ONCE ---
	air.ran_out.connect(_on_ran_out)
	air.breathe(1000.0)   # far more than is left
	check("can't go below zero", is_equal_approx(air.seconds_left, 0.0))
	check("empty tank is empty", air.is_empty())
	check("ran_out fired", _ran_out_count == 1)
	air.breathe(5.0)      # keep breathing an empty tank
	check("ran_out doesn't fire again", _ran_out_count == 1)

	# --- The bunker refills it, but never above full ---
	var b := CleanAir.new(480.0)
	b.breathe(100.0)
	b.refill(30.0)
	check("refill adds air", is_equal_approx(b.seconds_left, 410.0))
	b.refill(9999.0)
	check("refill stops at full", is_equal_approx(b.seconds_left, 480.0))

	# --- A filter cartridge: +4 minutes, flowing in over about 5 seconds (Brandon, 10-12) ---
	var f := CleanAir.new(480.0)
	f.breathe(300.0)   # 180 s left
	check("filter is accepted", f.use_filter())
	check("the air doesn't jump instantly", is_equal_approx(f.seconds_left, 180.0))
	f.flow_filter_air(1.0)   # 1 second later: 240 / 5 = 48 s of air has flowed in
	check("after 1 second, a fifth has flowed in", is_equal_approx(f.seconds_left, 228.0))
	f.flow_filter_air(4.0)
	check("after 5 seconds, all 4 minutes are in", is_equal_approx(f.seconds_left, 420.0))
	f.flow_filter_air(3.0)
	check("nothing more flows after that", is_equal_approx(f.seconds_left, 420.0))

	# --- Full tank: the filter is used anyway and its air is wasted (Brandon, 10-12) ---
	var topped := CleanAir.new(480.0)
	check("a full tank still takes the filter", topped.use_filter())
	topped.flow_filter_air(5.0)
	check("...but the air can't go above full", is_equal_approx(topped.seconds_left, 480.0))

	# --- Out of air = collapsed: only a teammate can save you, not your own filter ---
	var gone := CleanAir.new(480.0)
	gone.breathe(480.0)
	check("an empty tank can't take a filter", not gone.use_filter())
	var lender := CleanAir.new(480.0)
	lender.breathe(470.0)   # 10 s left
	lender.use_filter()     # air starts flowing in...
	lender.breathe(10.0)    # ...but they run out before any of it arrives
	lender.flow_filter_air(5.0)
	check("collapsing stops the filter's air", lender.is_empty())

	# --- Each filter ITEM says how much air it gives (Filter Cartridge item) ---
	var g := CleanAir.new(480.0)
	g.breathe(400.0)   # 80 s left
	g.use_filter(120.0)
	g.flow_filter_air(5.0)
	check("a smaller filter adds its own amount", is_equal_approx(g.seconds_left, 200.0))
	check("a filter worth 0 seconds is refused", not g.use_filter(0.0))
	g.flow_filter_air(5.0)
	check("that refusal didn't change the air", is_equal_approx(g.seconds_left, 200.0))
	# A normal tool (hammer, rope...) has clean_air_seconds = 0, so it can't fill your tank.
	check("a normal tool gives no air", is_equal_approx(ItemData.new().clean_air_seconds, 0.0))

	# --- Pressing R: using the item in your hands (item_user.gd) ---
	var filter_item := ItemData.new()
	filter_item.clean_air_seconds = 240.0
	var hammer_item := ItemData.new()      # clean_air_seconds stays 0
	var inv := Inventory.new()
	var tank := CleanAir.new(480.0)
	check("empty hands: nothing to use", ItemUser.use_held_item(inv, tank) == ItemUser.UseResult.EMPTY_HANDS)
	inv.pick_up(hammer_item)
	check("a hammer can't be used on the tank", ItemUser.use_held_item(inv, tank) == ItemUser.UseResult.CANT_USE)
	inv.drop(Inventory.hands_location())
	inv.pick_up(filter_item)
	check("full tank: filter used anyway, air wasted", ItemUser.use_held_item(inv, tank) == ItemUser.UseResult.WASTED)
	check("...and the wasted filter is gone", inv.hands == null)
	tank.flow_filter_air(5.0)   # let the wasted air finish flowing (it can't go above full)
	inv.pick_up(filter_item)
	tank.breathe(300.0)   # 180 s left
	check("filter used on a low tank", ItemUser.use_held_item(inv, tank) == ItemUser.UseResult.USED)
	tank.flow_filter_air(5.0)
	check("...4 minutes flowed in", is_equal_approx(tank.seconds_left, 420.0))
	check("...and it's gone from your hands", inv.hands == null)

	# --- Lending air to a teammate ---
	var me := CleanAir.new(480.0)
	var friend := CleanAir.new(480.0)
	friend.breathe(400.0)   # friend has 80 s left
	var given := me.lend_to(friend, 60.0)
	check("lend gives what was asked", is_equal_approx(given, 60.0))
	check("lender loses that air", is_equal_approx(me.seconds_left, 420.0))
	check("friend gains that air", is_equal_approx(friend.seconds_left, 140.0))
	var poor := CleanAir.new(480.0)
	poor.breathe(470.0)    # only 10 s left
	var needy := CleanAir.new(480.0)
	needy.breathe(480.0)   # empty
	check("can't lend more than you have", is_equal_approx(poor.lend_to(needy, 60.0), 10.0))
	var almost_full := CleanAir.new(480.0)
	almost_full.breathe(20.0)   # only room for 20 s
	check("can't overfill a friend", is_equal_approx(me.lend_to(almost_full, 60.0), 20.0))

	print("---- Clean Air tests: %d passed, %d failed ----" % [_passed, _failed])


func check(what: String, ok: bool) -> void:
	if ok:
		_passed += 1
		print("PASS  ", what)
	else:
		_failed += 1
		push_error("FAIL  " + what)


func _on_ran_out() -> void:
	_ran_out_count += 1
