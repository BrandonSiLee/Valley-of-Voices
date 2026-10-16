class_name CarryLimits
extends Node
## What you can and can't do because of what you're CARRYING.
##
## Brandon's rules (2026-10-15):
## - Holding a big TWO-HANDED item means you can't sprint and can't use your
##   wrist device. Small one-handed items block neither.
## - WEIGHT: the more you carry, the slower you move and the harder you
##   breathe, so your Clean Air drains faster.
##
## The RULES are static functions, so the tests can check them without a
## player. The node part applies them every frame: it changes the
## ProtoController's speeds and sprint switch, tells the AirTank how hard you're
## breathing, and the wrist gauge asks wrist_allowed() before raising your arm.
## Lives as a child of the player: main.tscn → ProtoController → CarryLimits.
## Vault: wiki/2 Building It/Code/player/carry_limits.gd

@export_group("Weight")
## Up to this many kg you feel nothing (the starting kit should weigh less).
@export var comfortable_kg: float = 10.0
## At this many kg (or more) you're as slow and out of breath as it gets.
@export var max_kg: float = 40.0
## Your speed when fully loaded (0.6 = 60% of normal).
@export var slowest_speed: float = 0.6
## How hard you breathe when fully loaded (1.5 = air drains 1.5x as fast).
@export var heaviest_breathing: float = 1.5

var _player: Node
var _backpack: Backpack
var _air_tank: AirTank
var _status: StatusEffects   # optional: where we report "HANDS FULL" / "HEAVY LOAD"
## The player's own settings, remembered at the start. We only ever take things
## AWAY (sprint, speed); we never go above what you set yourself.
var _sprint_setting := false
var _base_speed := 0.0
var _sprint_speed := 0.0


func _ready() -> void:
	_player = get_parent()
	_backpack = _player.get_node_or_null("Backpack") as Backpack
	_air_tank = _player.get_node_or_null("AirTank") as AirTank
	_status = _player.get_node_or_null("StatusEffects") as StatusEffects
	if _backpack == null:
		push_error("CarryLimits: needs a Backpack next to it under the player.")
	if "can_sprint" in _player:
		_sprint_setting = _player.get("can_sprint")
	if not _sprint_setting:
		push_warning("CarryLimits: sprinting is off. Tick 'Can Sprint' on ProtoController in the Inspector.")
	if "base_speed" in _player:
		_base_speed = _player.get("base_speed")
		_sprint_speed = _player.get("sprint_speed")


func _physics_process(_delta: float) -> void:
	if _backpack == null:
		return
	# Ask the rules every frame: picking something up or dropping it changes them.
	var inventory := _backpack.inventory
	if "can_sprint" in _player:
		_player.set("can_sprint", _sprint_setting and can_sprint(inventory))

	var loaded := load_fraction(inventory.total_weight(), comfortable_kg, max_kg)
	if "base_speed" in _player:
		var speed := speed_multiplier(loaded, slowest_speed)
		_player.set("base_speed", _base_speed * speed)
		_player.set("sprint_speed", _sprint_speed * speed)
	if _air_tank != null:
		_air_tank.breath_rate = breath_multiplier(loaded, heaviest_breathing)
	_report_status(inventory, loaded)


# Tell the wrist monitor's status list what's going on (if there is one).
func _report_status(inventory: Inventory, loaded: float) -> void:
	if _status == null:
		return
	if inventory.is_holding_two_handed():
		_status.set_effect(&"hands_full", "HANDS FULL: NO SPRINT")
	else:
		_status.clear_effect(&"hands_full")
	if loaded > 0.0:
		_status.set_effect(&"heavy_load", "HEAVY LOAD: AIR x%.2f" % breath_multiplier(loaded, heaviest_breathing))
	else:
		_status.clear_effect(&"heavy_load")


## For the wrist gauge: "may I raise the arm right now?"
func wrist_allowed() -> bool:
	return _backpack == null or can_use_wrist(_backpack.inventory)


# --- The rules (static = tests call e.g. CarryLimits.can_sprint(inventory) directly) ---

static func can_sprint(inventory: Inventory) -> bool:
	return not inventory.is_holding_two_handed()


static func can_use_wrist(inventory: Inventory) -> bool:
	return not inventory.is_holding_two_handed()


## How loaded you are: 0.0 = comfortable, 1.0 = as heavy as it gets.
## Example (10 kg comfortable, 40 kg max): 25 kg → (25 - 10) / (40 - 10) = 0.5.
static func load_fraction(weight_kg: float, comfortable: float, maximum: float) -> float:
	if maximum <= comfortable:
		return 0.0 if weight_kg <= comfortable else 1.0   # avoids dividing by zero
	return clampf((weight_kg - comfortable) / (maximum - comfortable), 0.0, 1.0)


## Your speed multiplier: 1.0 when not loaded, `slowest` when fully loaded.
## lerpf = "slide between two numbers" by the load (0.5 = exactly halfway).
static func speed_multiplier(loaded: float, slowest: float) -> float:
	return lerpf(1.0, slowest, loaded)


## How much faster your air drains: 1.0 when not loaded, `heaviest` when fully loaded.
static func breath_multiplier(loaded: float, heaviest: float) -> float:
	return lerpf(1.0, heaviest, loaded)
