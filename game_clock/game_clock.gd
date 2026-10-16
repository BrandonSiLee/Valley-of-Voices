extends Node
## The game's clock: night, dawn and how dangerous it is right now.
##
## This is an AUTOLOAD: Godot creates it once when the game starts and keeps it
## alive in every scene, so any script can ask "how long until dawn?" with
## GameClock.seconds_until_dawn() (wrist monitor, monsters, the air tank...).
## Register it in Project Settings → Globals → Autoload, name "GameClock".
##
## The RULES live in night_clock.gd (NightClock). This node only feeds it time
## every frame and lets you set the numbers in the Inspector.
## (No class_name on purpose: the autoload's name "GameClock" is how you reach it.)
## Vault: wiki/2 Building It/Code/game_clock/game_clock.gd

## Forwarded from the clock, so other scripts can connect to GameClock directly.
signal night_started
signal dawn_started

## How long a night lasts before dawn, in minutes (design doc: about 20).
## Set it to 1 to see dawn quickly while testing.
@export var night_minutes: float = 20.0
## How much faster Clean Air drains at dawn (4 = an 8-minute tank lasts 2 minutes).
@export var dawn_air_multiplier: float = 4.0
## 1 = danger rises steadily; 2 = calm start, sharp end.
@export var danger_curve: float = 2.0
## Start the night as soon as the game runs. Turn off once the lift starts the
## night (First Playable step 8).
@export var start_night_on_launch: bool = true
## Print the time to the Output panel every minute (and at dawn).
@export var debug_print: bool = true

## The rules object. Other scripts can read it, but usually use the helpers below.
var clock: NightClock

var _print_timer: float = 0.0


func _ready() -> void:
	clock = NightClock.new(night_minutes * 60.0)
	clock.dawn_air_multiplier = dawn_air_multiplier
	clock.danger_curve = danger_curve
	clock.night_started.connect(_on_night_started)
	clock.dawn_started.connect(_on_dawn_started)
	if start_night_on_launch:
		clock.start_night()


func _process(delta: float) -> void:
	clock.advance(delta)
	if debug_print and clock.phase == NightClock.Phase.NIGHT:
		_print_timer += delta
		if _print_timer >= 60.0:
			_print_timer = 0.0
			print("Night: %s until dawn  (danger %.2f)" % [_as_clock(clock.seconds_until_dawn()), clock.danger_level()])


# --- Helpers so other scripts can write GameClock.danger_level() etc. ---

func start_night() -> void:
	clock.start_night()


func end_night() -> void:
	clock.end_night()


func is_dawn() -> bool:
	return clock.is_dawn()


func seconds_until_dawn() -> float:
	return clock.seconds_until_dawn()


func danger_level() -> float:
	return clock.danger_level()


func air_drain_multiplier() -> float:
	return clock.air_drain_multiplier()


# --- Private ---

func _on_night_started() -> void:
	_print_timer = 0.0
	if debug_print:
		print("Night started: %s until dawn" % _as_clock(clock.seconds_until_dawn()))
	night_started.emit()


func _on_dawn_started() -> void:
	if debug_print:
		print("DAWN! The air is turning. Get back to the bunker.")
	dawn_started.emit()


# Turns seconds into "m:ss", e.g. 125.0 → "2:05".
func _as_clock(seconds: float) -> String:
	var whole := ceili(seconds)
	return "%d:%02d" % [floori(whole / 60.0), whole % 60]
