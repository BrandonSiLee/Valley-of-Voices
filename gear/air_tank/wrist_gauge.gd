class_name WristGauge
extends Node3D
## The wrist monitor. Hold Tab to raise your arm and read it.
##
## It shows three things (Brandon, 2026-10-15):
##   1. your Clean Air (the needle: full = right, empty = left; shakes when low),
##   2. the time until sunrise (a text label),
##   3. your status effects: "HEAVY LOAD", "TOXIC AIR"... (a text label).
## It doesn't know any rules: it only ASKS the AirTank, the GameClock autoload
## and the StatusEffects list, then shows what they say.
## It follows the camera by itself, so it can sit next to the Backpack under
## ProtoController without touching the addon: main.tscn → ProtoController →
## WristGauge (an instance of wrist_gauge.tscn).
## Carrying something with both hands? Then the arm won't come up: it asks
## CarryLimits (player/carry_limits.gd) first.
## Vault: wiki/2 Building It/Code/gear/air_tank/wrist_gauge.gd

## The input action that raises the wrist (Project Settings → Input Map).
const ACTION := "check_air"

## The part that turns. It spins around its own Z axis (the axis pointing out
## of the dial face, towards your eyes).
@export var needle: Node3D
## Whose air to show. Leave empty: it finds the AirTank next to it by itself.
@export var air_tank: AirTank

@export_group("Screen")
## Text on the wrist showing the time until sunrise. Optional.
@export var dawn_label: Label3D
## Text on the wrist listing your status effects. Optional.
@export var status_label: Label3D

@export_group("Needle")
## Needle angle when the tank is EMPTY, in degrees.
@export var empty_angle: float = 120.0
## Needle angle when the tank is FULL, in degrees.
@export var full_angle: float = -120.0
## Below this fraction (0.2 = 20%) the needle starts shaking.
@export var low_air: float = 0.2
## How hard the needle shakes when air is low, in degrees.
@export var shake_degrees: float = 4.0

@export_group("Arm")
## Where the wrist sits in front of the camera when RAISED (x right, y up,
## z forward is NEGATIVE). Tweak these while the game runs to line it up.
@export var raised_offset: Vector3 = Vector3(0.12, -0.18, -0.4)
## Where it hides when lowered (below the bottom of the screen).
@export var lowered_offset: Vector3 = Vector3(0.25, -0.7, -0.4)
## How fast the arm moves up and down. Bigger = snappier.
@export var raise_speed: float = 10.0

var _offset: Vector3   # where the wrist is right now, between lowered and raised
var _carry_limits: CarryLimits   # optional: without one, the wrist is always allowed
var _status: StatusEffects       # optional: without one, the wrist says "STATUS OK"


func _ready() -> void:
	# top_level = ignore the parent's movement; we place ourselves every frame.
	top_level = true
	_offset = lowered_offset
	if air_tank == null:
		air_tank = _find_air_tank()
	if get_parent() != null:
		_carry_limits = get_parent().get_node_or_null("CarryLimits") as CarryLimits
		_status = get_parent().get_node_or_null("StatusEffects") as StatusEffects
	if air_tank == null:
		push_warning("WristGauge: no AirTank found next to me, the needle won't move.")
	if not InputMap.has_action(ACTION):
		push_warning("WristGauge: add an input action called '%s' (Tab) in Project Settings → Input Map." % ACTION)


func _process(delta: float) -> void:
	_move_arm(delta)
	_update_needle()
	_update_screen()


## THE TEXT RULE for sunrise. `static` so the tests can call it directly.
## Night: "SUNRISE 12:05" (time left). Dawn: "SUNRISE! +0:30" (time since). Day: "".
static func dawn_text(phase: NightClock.Phase, seconds_until: float, seconds_since: float) -> String:
	match phase:
		NightClock.Phase.NIGHT:
			return "SUNRISE " + _as_clock(seconds_until)
		NightClock.Phase.DAWN:
			return "SUNRISE! +" + _as_clock(seconds_since)
	return ""


## THE TEXT RULE for status effects: one per line, or "STATUS OK" if none.
static func status_text(lines: PackedStringArray) -> String:
	if lines.is_empty():
		return "STATUS OK"
	return "\n".join(lines)


# Slide towards raised (Tab held) or lowered, then stick to the camera.
func _move_arm(delta: float) -> void:
	var raised := InputMap.has_action(ACTION) and Input.is_action_pressed(ACTION)
	# Both hands full? Then the arm stays down, even while Tab is held.
	if _carry_limits != null and not _carry_limits.wrist_allowed():
		raised = false
	var target := raised_offset if raised else lowered_offset
	# "Smooth follow": cover a fixed share of the remaining distance each frame.
	# exp() keeps the speed the same on slow and fast PCs (lesson from step 3!).
	_offset = _offset.lerp(target, 1.0 - exp(-raise_speed * delta))

	var camera := get_viewport().get_camera_3d()
	if camera:
		# Start at the camera, then step _offset along the camera's own axes.
		global_transform = camera.global_transform * Transform3D(Basis.IDENTITY, _offset)


func _update_needle() -> void:
	if needle == null or air_tank == null or air_tank.air == null:
		return
	var percent := air_tank.air.get_percent()
	# lerpf = "slide between two numbers": 0.0 gives empty_angle, 1.0 full_angle.
	var angle := lerpf(empty_angle, full_angle, percent)
	if percent < low_air:
		angle += randf_range(-shake_degrees, shake_degrees)
	needle.rotation.z = deg_to_rad(angle)


func _update_screen() -> void:
	if dawn_label != null:
		var clock := _find_night_clock()
		dawn_label.text = "" if clock == null else dawn_text(clock.phase, clock.seconds_until_dawn(), clock.seconds_since_dawn())
	if status_label != null:
		status_label.text = status_text(PackedStringArray() if _status == null else _status.get_lines())


# The rules object inside the GameClock autoload (null if it isn't registered).
func _find_night_clock() -> NightClock:
	var game_clock := get_node_or_null("/root/GameClock")
	if game_clock == null:
		return null
	return game_clock.get("clock") as NightClock


# Looks at our siblings (the other children of the player) for an AirTank.
func _find_air_tank() -> AirTank:
	if get_parent() == null:
		return null
	for child in get_parent().get_children():
		if child is AirTank:
			return child as AirTank
	return null


# Turns seconds into "m:ss", rounding UP so the wrist never says 0:00 too early.
static func _as_clock(seconds: float) -> String:
	var whole := ceili(seconds)
	return "%d:%02d" % [floori(whole / 60.0), whole % 60]
