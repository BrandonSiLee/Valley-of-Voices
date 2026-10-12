class_name DeathFade
extends ColorRect
## A black screen that fades in when your Clean Air runs out: you've "died".
##
## It listens to the AirTank's air: when the "ran_out" signal fires, the screen
## fades to black and the player can't move any more. (Reviving by a teammate
## comes later.) It only reacts to the air: it doesn't know the air rules.
## Put it on a full-screen ColorRect inside a CanvasLayer:
## main.tscn → ProtoController → DeathLayer (CanvasLayer) → DeathFade.
## Vault: wiki/2 Building It/Code/player/death_fade.gd

## Whose air to watch. Leave empty: it finds the player's AirTank by itself.
@export var air_tank: AirTank
## How long the fade to black takes, in seconds.
@export var fade_seconds: float = 2.0


func _ready() -> void:
	# Start fully see-through, and never block mouse clicks meant for other UI
	# (like the inventory screen) while invisible.
	color = Color.BLACK
	modulate.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Wait one frame before connecting: the AirTank creates its `air` in its own
	# _ready(), and that may run AFTER ours, depending on the node order.
	_connect_to_air.call_deferred()


func _connect_to_air() -> void:
	if air_tank == null:
		air_tank = _find_air_tank()
	if air_tank == null or air_tank.air == null:
		push_warning("DeathFade: no AirTank found, the screen will never fade.")
		return
	air_tank.air.ran_out.connect(_on_air_ran_out)


func _on_air_ran_out() -> void:
	# A Tween animates a value over time: here the alpha (see-through-ness)
	# goes from 0 (invisible) to 1 (solid black) in fade_seconds.
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_seconds)
	_stop_player()


# The ProtoController addon has a `can_move` switch; we flip it from here
# instead of editing the addon (same trick as tool_box.gd). `player` is a plain
# Node, which has no "can_move", so set() looks it up by NAME at runtime.
func _stop_player() -> void:
	var player := air_tank.get_parent()
	if player and "can_move" in player:
		player.set("can_move", false)


# Walks UP the tree (CanvasLayer, then ProtoController, ...) and looks at each
# level's children for an AirTank, so it works wherever you put the fade.
func _find_air_tank() -> AirTank:
	var node := get_parent()
	while node:
		for child in node.get_children():
			if child is AirTank:
				return child as AirTank
		node = node.get_parent()
	return null
