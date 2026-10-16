class_name NightClock
extends RefCounted
## The RULES of the night clock. No visuals here at all.
##
## DAY → NIGHT → DAWN → (back home) DAY.
## - DAY: you're in the bunker; no timer (the team decides when to go, design doc).
## - NIGHT: about 20 minutes on the surface. Monsters are always there but get
##   more aware and aggressive as the night goes on (Brandon, 2026-10-15): that's
##   danger_level(), a number from 0 (calm) to 1 (as angry as they get).
## - DAWN: the night doesn't hard-stop. The algae wake up, the air turns
##   poisonous and your Clean Air drains much faster: air_drain_multiplier().
##
## The GameClock node (game_clock.gd, an autoload) owns one of these and
## advances it every frame. Keeping the rules here means they're easy to test.
## Vault: wiki/2 Building It/Code/game_clock/night_clock.gd

## Emitted when the night begins.
signal night_started
## Emitted once, at the moment dawn breaks.
signal dawn_started

enum Phase { DAY, NIGHT, DAWN }

## How long a night lasts before dawn, in seconds (1200 = 20 minutes).
var night_seconds: float
## How much faster your air drains at dawn (4.0 = an 8-minute tank lasts 2 minutes).
var dawn_air_multiplier: float = 4.0
## Shape of the danger curve. 1 = steady rise. 2 = calm start, sharp end
## (halfway through the night the danger is only 0.25).
var danger_curve: float = 2.0

var phase := Phase.DAY
## Seconds since the night started (keeps counting after dawn).
var elapsed: float = 0.0


## Runs when you write NightClock.new(...).
func _init(length_seconds: float = 1200.0) -> void:
	night_seconds = length_seconds


## The team leaves the bunker: a new night starts from zero.
func start_night() -> void:
	phase = Phase.NIGHT
	elapsed = 0.0
	night_started.emit()


## Everyone's home (or the night is over): back to day. The clock stops.
func end_night() -> void:
	phase = Phase.DAY
	elapsed = 0.0


## Let `delta` seconds pass. Does nothing during the day.
func advance(delta: float) -> void:
	if phase == Phase.DAY:
		return
	elapsed += delta
	# Checking ">=" (not "==") means even one huge, slow frame lands on dawn.
	if phase == Phase.NIGHT and elapsed >= night_seconds:
		phase = Phase.DAWN
		dawn_started.emit()


func is_dawn() -> bool:
	return phase == Phase.DAWN


## Seconds left until dawn (0 once it's dawn; a whole night during the day).
func seconds_until_dawn() -> float:
	if phase == Phase.DAY:
		return night_seconds
	return maxf(night_seconds - elapsed, 0.0)


## How long ago dawn broke (0 before dawn).
func seconds_since_dawn() -> float:
	if phase != Phase.DAWN:
		return 0.0
	return elapsed - night_seconds


## How aware and aggressive monsters are: 0.0 = calm, 1.0 = maximum.
func danger_level() -> float:
	match phase:
		Phase.NIGHT:
			var progress := clampf(elapsed / maxf(night_seconds, 0.01), 0.0, 1.0)
			return pow(progress, danger_curve)   # pow(0.5, 2) = 0.25
		Phase.DAWN:
			return 1.0
	return 0.0   # day: no monsters around you


## How much faster Clean Air drains right now because of the time (1.0 = normal).
func air_drain_multiplier() -> float:
	return dawn_air_multiplier if phase == Phase.DAWN else 1.0
