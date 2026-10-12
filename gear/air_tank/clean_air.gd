class_name CleanAir
extends RefCounted
## The RULES of your Clean Air. No visuals here at all.
##
## Clean Air is your health bar AND your clock: it drains while you breathe
## on the surface, the bunker refills it, a Filter Cartridge's air flows in
## over a few seconds, and you can lend some to a teammate. At 0 you "run out".
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

## A normal Filter Cartridge, in seconds (240 = 4 minutes). Only used when
## use_filter() is called without a number. The real amount comes from the
## item itself (ItemData.clean_air_seconds), so a bigger filter needs no new code.
const DEFAULT_FILTER_SECONDS := 240.0

## How much a full tank holds, in seconds (480 = 8 minutes).
var max_seconds: float
## How much is left right now, in seconds.
var seconds_left: float
## How long a filter's air takes to flow into the tank, in real seconds.
## (Brandon, 2026-10-12: "it quickly rises", not an instant jump.)
var filter_rise_seconds: float = 5.0
## Filter air that's clicked in but hasn't reached the tank yet, in seconds of air.
var incoming_seconds: float = 0.0

# How fast the incoming air flows, in seconds of air per real second.
# e.g. 240 s of air over 5 real seconds = 48 per second.
var _flow_rate: float = 0.0


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


## Click in a Filter Cartridge worth `seconds` of air. The air doesn't arrive
## at once: it's queued in `incoming_seconds` and flow_filter_air() lets it in
## over `filter_rise_seconds`. Returns true if the filter was used up.
## A full tank still takes it (Brandon, 2026-10-12: your choice, your loss):
## the extra air is simply wasted. Returns false (filter NOT used) if it gives
## no air at all (e.g. a hammer) or if you've collapsed (only a teammate can
## save you then).
func use_filter(seconds: float = DEFAULT_FILTER_SECONDS) -> bool:
	if seconds <= 0.0 or is_empty():
		return false
	incoming_seconds += seconds
	# Everything still incoming (this filter + any left from the last one)
	# finishes flowing in `filter_rise_seconds` from now.
	_flow_rate = incoming_seconds / maxf(filter_rise_seconds, 0.01)
	return true


## Let a bit of the clicked-in filter air into the tank. The tank calls this
## every frame with `delta`, so the gauge needle sweeps up smoothly.
func flow_filter_air(delta: float) -> void:
	if incoming_seconds <= 0.0:
		return
	if is_empty():
		incoming_seconds = 0.0   # you collapsed before it arrived: it's lost
		return
	var amount := minf(incoming_seconds, _flow_rate * delta)   # never more than what's left
	incoming_seconds -= amount
	refill(amount)   # refill() stops at full, so on a full tank it's wasted


func is_full() -> bool:
	return seconds_left >= max_seconds


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
