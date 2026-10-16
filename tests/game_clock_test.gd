extends Node
## Automatic checks for the night clock rules (game_clock/night_clock.gd).
##
## HOW TO RUN: open tests/game_clock_test.tscn and press F6.
## Look at the Output panel: every line should say PASS.
## If you ever change night_clock.gd, run this again to make sure nothing broke.
## Vault: wiki/2 Building It/Code/tests/game_clock_test.gd

var _passed := 0
var _failed := 0
var _dawn_count := 0   # how many times the "dawn_started" signal fired


func _ready() -> void:
	# --- Before the night: it's day, the clock stands still ---
	var clock := NightClock.new(1200.0)   # a 20-minute night
	check("starts in the day", clock.phase == NightClock.Phase.DAY)
	clock.advance(100.0)
	check("time doesn't run during the day", is_equal_approx(clock.elapsed, 0.0))
	check("no danger during the day", is_equal_approx(clock.danger_level(), 0.0))

	# --- The night starts ---
	clock.dawn_started.connect(_on_dawn_started)
	clock.start_night()
	check("start_night: it's night", clock.phase == NightClock.Phase.NIGHT)
	check("a whole night until dawn", is_equal_approx(clock.seconds_until_dawn(), 1200.0))
	check("night just started: danger 0", is_equal_approx(clock.danger_level(), 0.0))
	check("normal air drain at night", is_equal_approx(clock.air_drain_multiplier(), 1.0))

	# --- Time passes ---
	clock.advance(600.0)   # halfway
	check("halfway: 10 minutes until dawn", is_equal_approx(clock.seconds_until_dawn(), 600.0))
	# The danger curve (2 = squared) keeps early night calm and makes the end sharp:
	# halfway through the night, danger is only 0.5 x 0.5 = 0.25.
	check("halfway: danger 0.25 (slow start)", is_equal_approx(clock.danger_level(), 0.25))
	check("still night halfway", not clock.is_dawn())

	# --- Dawn (Brandon: dawn doesn't stop the night, it burns your air) ---
	clock.advance(600.0)
	check("after 20 minutes: dawn", clock.is_dawn())
	check("dawn_started fired", _dawn_count == 1)
	check("dawn: danger at the maximum", is_equal_approx(clock.danger_level(), 1.0))
	check("dawn: air drains faster", clock.air_drain_multiplier() > 1.0)
	check("dawn: 0 seconds until dawn", is_equal_approx(clock.seconds_until_dawn(), 0.0))
	clock.advance(30.0)
	check("dawn keeps going (no hard stop)", clock.is_dawn())
	check("counts time since dawn", is_equal_approx(clock.seconds_since_dawn(), 30.0))
	check("dawn_started only fires once", _dawn_count == 1)

	# --- One big jump (a slow frame) still lands on dawn correctly ---
	var jump := NightClock.new(1200.0)
	jump.start_night()
	jump.advance(5000.0)
	check("one huge step still reaches dawn", jump.is_dawn())

	# --- Back home: the night ends, it's day again ---
	clock.end_night()
	check("end_night: day again", clock.phase == NightClock.Phase.DAY)
	check("day: normal air drain", is_equal_approx(clock.air_drain_multiplier(), 1.0))

	# --- A new night starts fresh ---
	clock.start_night()
	check("next night starts from 0", is_equal_approx(clock.elapsed, 0.0))
	check("next night: danger back to 0", is_equal_approx(clock.danger_level(), 0.0))

	print("---- Game Clock tests: %d passed, %d failed ----" % [_passed, _failed])


func check(what: String, ok: bool) -> void:
	if ok:
		_passed += 1
		print("PASS  ", what)
	else:
		_failed += 1
		push_error("FAIL  " + what)


func _on_dawn_started() -> void:
	_dawn_count += 1
