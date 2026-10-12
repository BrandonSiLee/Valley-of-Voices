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

var _print_timer: float = 0.0
# How many bunker zones we're standing in right now. A number instead of
# true/false, so two zones that overlap at a doorway can't confuse us.
var _bunker_zones: int = 0


func _ready() -> void:
	# Build the rules with the numbers from the Inspector.
	air = CleanAir.new(tank_seconds)
	air.filter_rise_seconds = filter_rise_seconds
	air.ran_out.connect(_on_air_ran_out)


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
		air.breathe(delta)
	# A clicked-in filter's air arrives a little each frame (inside or outside).
	air.flow_filter_air(delta)
	if debug_print:
		_print_timer += delta
		if _print_timer >= 1.0:
			_print_timer = 0.0
			var where := "bunker, refilling" if is_in_bunker() else "surface"
			print("Clean Air: %d%%  (%s left, %s)" % [roundi(air.get_percent() * 100.0), _as_clock(air.seconds_left), where])


## A BunkerAirZone calls this when the player walks in.
func enter_bunker() -> void:
	_bunker_zones += 1


## A BunkerAirZone calls this when the player walks out.
func leave_bunker() -> void:
	_bunker_zones = maxi(_bunker_zones - 1, 0)


func is_in_bunker() -> bool:
	return _bunker_zones > 0


func _on_air_ran_out() -> void:
	print("Out of clean air!")   # the fade to black itself lives in player/death_fade.gd


# Turns seconds into "m:ss", e.g. 125.0 → "2:05".
func _as_clock(seconds: float) -> String:
	var whole := ceili(seconds)
	return "%d:%02d" % [floori(whole / 60.0), whole % 60]
