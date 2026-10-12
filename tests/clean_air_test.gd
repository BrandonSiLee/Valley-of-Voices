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

	# --- A filter cartridge adds 4 minutes ---
	var f := CleanAir.new(480.0)
	f.breathe(300.0)   # 180 s left
	check("filter is used when not full", f.use_filter())
	check("filter adds 4 minutes", is_equal_approx(f.seconds_left, 420.0))
	check("a filter is refused when the tank is full", not CleanAir.new(480.0).use_filter())

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
