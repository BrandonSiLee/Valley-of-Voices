class_name CleanAir
extends RefCounted
## The RULES of your Clean Air. No visuals here at all.
##
## Clean Air is your health bar AND your clock: it drains while you breathe
## on the surface, the bunker refills it, a Filter Cartridge adds 4 minutes,
## and you can lend some to a teammate. At 0 you "run out".
## Air is counted in SECONDS of breathing, so "480" simply means 8 minutes.
## The tank on your back (air_tank.gd) and the wrist gauge only USE this
## script. Keeping the rules here means they're easy to test and easy to sync
## in multiplayer later.
##
## RefCounted = a plain object that frees itself when nothing uses it.
## Vault: wiki/2 Building It/Code/gear/air_tank/clean_air.gd

## Emitted whenever the amount of air changes, so a gauge knows to update.
signal changed
## Emitted once, at the moment the tank hits zero.
signal ran_out

## How much a full tank holds, in seconds (480 = 8 minutes).
var max_seconds: float
## How much is left right now, in seconds.
var seconds_left: float
## How much one Filter Cartridge adds, in seconds (240 = 4 minutes).
var filter_seconds: float = 240.0


## Runs when you write CleanAir.new(...). A new tank always starts full.
func _init(tank_seconds: float = 480.0) -> void:
	max_seconds = tank_seconds
	seconds_left = tank_seconds


## Breathe for `delta` seconds: the air goes down by that much.
func breathe(delta: float) -> void:
	if is_empty():
		return   # already empty: nothing to drain, and don't fire ran_out again
	_set_seconds(seconds_left - delta)
	if is_empty():
		ran_out.emit()


## Add air (the bunker calls this a little every frame). Never above full.
func refill(seconds: float) -> void:
	_set_seconds(seconds_left + seconds)


## Click in a Filter Cartridge. Returns false (filter NOT used up) if the
## tank is already full, so the player doesn't waste it.
func use_filter() -> bool:
	if seconds_left >= max_seconds:
		return false
	refill(filter_seconds)
	return true


## Give up to `seconds` of your air to `other`. You can't give more than you
## have, and they can't take more than fits. Returns how much was really given.
func lend_to(other: CleanAir, seconds: float) -> float:
	var room_in_other := other.max_seconds - other.seconds_left
	var amount := minf(seconds, minf(seconds_left, room_in_other))
	if amount <= 0.0:
		return 0.0
	breathe(amount)        # we lose it (and may run out ourselves: a sacrifice!)
	other.refill(amount)   # they gain it
	return amount


## How full the tank is, from 0.0 (empty) to 1.0 (full). Handy for gauges.
func get_percent() -> float:
	if max_seconds <= 0.0:
		return 0.0
	return seconds_left / max_seconds


func is_empty() -> bool:
	return seconds_left <= 0.0


# The ONE place that changes seconds_left. clampf keeps it between 0 and full,
# so no other function has to worry about going too low or too high.
func _set_seconds(value: float) -> void:
	var clamped := clampf(value, 0.0, max_seconds)
	# Exact == on purpose (NOT is_equal_approx): on a fast PC one frame's breath
	# is tiny (~0.001 s), and "approximately equal" would throw it away, so the
	# air would never drain. Only skip when the number truly didn't move, e.g.
	# refilling a tank that's already full.
	if clamped == seconds_left:
		return   # nothing changed: don't bother the gauge
	seconds_left = clamped
	changed.emit()
