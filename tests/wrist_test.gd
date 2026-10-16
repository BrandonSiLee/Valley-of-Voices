extends Node
## Automatic checks for the wrist monitor: the status effects list
## (player/status_effects.gd) and the text the wrist shows (wrist_gauge.gd).
##
## HOW TO RUN: open tests/wrist_test.tscn and press F6.
## Look at the Output panel: every line should say PASS.
## Vault: wiki/2 Building It/Code/tests/wrist_test.gd

var _passed := 0
var _failed := 0
var _changed_count := 0   # how many times the "changed" signal fired


func _ready() -> void:
	# --- Status effects: any system can report one, by a short id ---
	var status := StatusEffects.new()
	status.changed.connect(_on_status_changed)
	check("starts with no effects", status.get_lines().is_empty())
	status.set_effect(&"hands_full", "HANDS FULL")
	check("an effect shows up", status.has_effect(&"hands_full") and status.get_lines() == PackedStringArray(["HANDS FULL"]))
	check("changed fired", _changed_count == 1)
	status.set_effect(&"hands_full", "HANDS FULL")
	check("same effect, same text: no change, no signal", status.get_lines().size() == 1 and _changed_count == 1)
	status.set_effect(&"hands_full", "BOTH HANDS FULL")
	check("same effect, new text: replaced, not doubled", status.get_lines() == PackedStringArray(["BOTH HANDS FULL"]))
	status.set_effect(&"toxic_air", "TOXIC AIR")
	check("two effects, in the order they started", status.get_lines() == PackedStringArray(["BOTH HANDS FULL", "TOXIC AIR"]))
	status.clear_effect(&"hands_full")
	check("clearing removes it", not status.has_effect(&"hands_full") and status.get_lines() == PackedStringArray(["TOXIC AIR"]))
	var before := _changed_count
	status.clear_effect(&"not_there")
	check("clearing an effect that isn't there is fine (no signal)", _changed_count == before)
	status.free()   # a Node made in code must be freed by hand

	# --- What the wrist says about sunrise ---
	check("night: time until sunrise", WristGauge.dawn_text(NightClock.Phase.NIGHT, 725.0, 0.0) == "SUNRISE 12:05")
	check("night: rounds UP (never shows 0:00 early)", WristGauge.dawn_text(NightClock.Phase.NIGHT, 0.4, 0.0) == "SUNRISE 0:01")
	check("dawn: how long ago it broke", WristGauge.dawn_text(NightClock.Phase.DAWN, 0.0, 30.0) == "SUNRISE! +0:30")
	check("day: no timer", WristGauge.dawn_text(NightClock.Phase.DAY, 1200.0, 0.0) == "")

	# --- What the wrist says about status effects ---
	check("no effects: all clear", WristGauge.status_text(PackedStringArray()) == "STATUS OK")
	check("effects: one per line", WristGauge.status_text(PackedStringArray(["HEAVY LOAD", "TOXIC AIR"])) == "HEAVY LOAD\nTOXIC AIR")

	print("---- Wrist tests: %d passed, %d failed ----" % [_passed, _failed])


func check(what: String, ok: bool) -> void:
	if ok:
		_passed += 1
		print("PASS  ", what)
	else:
		_failed += 1
		push_error("FAIL  " + what)


func _on_status_changed() -> void:
	_changed_count += 1
