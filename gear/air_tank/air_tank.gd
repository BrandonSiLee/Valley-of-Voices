class_name AirTank
extends Node
## The Clean Air tank on the player's back.
##
## It owns ONE CleanAir (the rules, see clean_air.gd) and makes you breathe it
## every frame, so your air goes down while you play. Inside the bunker
## (a BunkerAirZone tells us when we enter and leave) it slowly refills instead.
## Other things (the wrist gauge, the fade to black) talk to this node to read
## or react to it.
## Lives as a child of the player: main.tscn → ProtoController → AirTank.
## Vault: wiki/2 Building It/Code/gear/air_tank/air_tank.gd

## How long a full tank lasts, in seconds (480 = 8 minutes).
## Set it to something small like 20 in the Inspector to test quickly.
@export var tank_seconds: float = 480.0
# (How much a Filter Cartridge adds is NOT set here: each filter item says it
# itself, in its .tres file → ItemData.clean_air_seconds.)
## How many real seconds a filter's air takes to flow into the tank.
@export var filter_rise_seconds: float = 5.0
## Inside the bunker: how many seconds it takes to refill an EMPTY tank to full.
## Smaller = faster refill.
@export var bunker_refill_seconds: float = 120.0
## Print the air level to the Output panel once a second (for testing).
@export var debug_print: bool = true

## The rules object. Other scripts read it, e.g. air_tank.air.get_percent().
var air: CleanAir
## How hard you're breathing: 1.0 = normal, 1.5 = air drains 1.5x as fast.
## Set from outside every frame (player/carry_limits.gd: a heavy pack).
## Dawn is added on top of this (see _time_of_day_multiplier()).
var breath_rate: float = 1.0

var _print_timer: float = 0.0
var _status: StatusEffects   # optional: the wrist monitor's status list (a sibling)
# How many bunker zones we're standing in right now. A number instead of
# true/false, so two zones that overlap at a doorway can't confuse us.
var _bunker_zones: int = 0


func _ready() -> void:
	# Build the rules with the numbers from the Inspector.
	air = CleanAir.new(tank_seconds)
	air.filter_rise_seconds = filter_rise_seconds
	air.ran_out.connect(_on_air_ran_out)
	if get_parent() != null:
		_status = get_parent().get_node_or_null("StatusEffects") as StatusEffects


# _process runs every frame. `delta` = seconds since the last frame
# (about 0.016 at 60 FPS), so breathing `delta` drains exactly 1 second of
# air per real second, however fast or slow the computer is.
func _process(delta: float) -> void:
	if is_in_bunker():
		# Refill speed = a full tank divided by the refill time.
		# e.g. 480 s / 120 s = 4 seconds of air back per real second.
		# maxf(..., 0.1) stops a crash if someone types 0 in the Inspector.
		air.refill(air.max_seconds / maxf(bunker_refill_seconds, 0.1) * delta)
	else:
		# Breathing harder (heavy pack) and dawn (poison air) both use more air per second.
		air.breathe(delta * breath_rate * _time_of_day_multiplier())
	_report_status()
	# A clicked-in filter's air arrives a little each frame (inside or outside).
	air.flow_filter_air(delta)
	if debug_print:
		_print_timer += delta
		if _print_timer >= 1.0:
			_print_timer = 0.0
			# Show the TOTAL: heavy pack x dawn (not just the pack, which hid dawn).
			var where := "bunker, refilling" if is_in_bunker() else "surface, breathing x%.2f" % (breath_rate * _time_of_day_multiplier())
			print("Clean Air: %d%%  (%s left, %s)" % [roundi(air.get_percent() * 100.0), _as_clock(air.seconds_left), where])


## A BunkerAirZone calls this when the player walks in.
func enter_bunker() -> void:
	_bunker_zones += 1


## A BunkerAirZone calls this when the player walks out.
func leave_bunker() -> void:
	_bunker_zones = maxi(_bunker_zones - 1, 0)


func is_in_bunker() -> bool:
	return _bunker_zones > 0


## Dawn makes the air drain faster. Asks the GameClock autoload; if it isn't
## registered (e.g. in a test scene), the time of day changes nothing.
func _time_of_day_multiplier() -> float:
	var game_clock := get_node_or_null("/root/GameClock")
	if game_clock == null or not game_clock.has_method("air_drain_multiplier"):
		return 1.0
	# call() looks the function up by NAME, because Godot only knows this is "a Node".
	return float(game_clock.call("air_drain_multiplier"))


## Report "TOXIC AIR" to the wrist monitor's status list while dawn is burning
## your air on the surface. (In the bunker you're safe, so it goes away.)
func _report_status() -> void:
	if _status == null:
		return
	var multiplier := _time_of_day_multiplier()
	if multiplier > 1.0 and not is_in_bunker():
		_status.set_effect(&"toxic_air", "TOXIC AIR: x%.0f DRAIN" % multiplier)
	else:
		_status.clear_effect(&"toxic_air")


func _on_air_ran_out() -> void:
	print("Out of clean air!")   # the fade to black itself lives in player/death_fade.gd


# Turns seconds into "m:ss", e.g. 125.0 → "2:05".
func _as_clock(seconds: float) -> String:
	var whole := ceili(seconds)
	return "%d:%02d" % [floori(whole / 60.0), whole % 60]
