class_name Backpack
extends Node3D
## The player's Backpack: worn on your back, opened with B.
## It replaces the Tool Box (Brandon, 2026-10-15: "a backpack like in Death Stranding").
##
## Put this scene as a CHILD of the player. When you press B:
##   1. you stop moving (you can only open it standing still, on the ground),
##   2. the pack swings off your right shoulder and round to in front of you,
##   3. the flap opens,
##   4. you look down into it (the camera zooms in),
##   5. the grid inventory fades in. The world keeps going, but you can't see it.
## Press B (or Esc) again and it all plays backwards.
##
## This script only handles the 3D pack, the animation and freezing the player.
## The inventory RULES are in inventory.gd and the SCREEN is in ui/inventory_ui.gd,
## so swapping the Tool Box for a backpack didn't touch the rules at all.
## Vault: wiki/2 Building It/Code/gear/backpack/backpack.gd

signal opened
signal closed
## Something to tell the player, e.g. "No room in your backpack".
signal message(text: String)

## CLOSED -> OPENING -> OPEN -> CLOSING -> CLOSED. Input is ignored while animating.
enum State { CLOSED, OPENING, OPEN, CLOSING }

const DROPPED_ITEM_SCENE := preload("res://items/dropped_item.tscn")
## Used when `starting_items` is left empty in the Inspector.
const DEFAULT_ITEMS: Array[String] = [
	"res://items/walkie_talkie.tres",
	"res://items/flashlight.tres",
	"res://items/battery.tres",
	"res://items/hammer.tres",
	"res://items/crowbar.tres",
]

## Items you start with (drag .tres files in here). Empty = DEFAULT_ITEMS.
@export var starting_items: Array[ItemData] = []

# The three poses the pack moves through. They are in CAMERA space:
# x = right, y = up, -z = forward, in metres. Tilt = how far the top of the
# pack tips toward your face, in degrees. Tweak them in the Inspector while
# the game runs until the swing looks right (no code needed).
@export_group("Poses")
## 1. Off your right shoulder, close to your head.
@export var shoulder_position := Vector3(0.35, -0.2, -0.2)
@export var shoulder_tilt := 10.0
## 2. Held in front of you at chest height.
@export var front_position := Vector3(0.0, -0.4, -0.55)
@export var front_tilt := 35.0
## 3. Looking down into the open pack.
@export var look_position := Vector3(0.0, -0.28, -0.4)
@export var look_tilt := 70.0

@export_group("Animation")
## Seconds for each animation step. Smaller = snappier.
@export var step_time := 0.3
## Camera field of view while looking into the pack (smaller = more zoomed in).
@export var zoom_fov := 50.0
## How far the flap swings open, in degrees.
@export var flap_open_degrees := -120.0

var inventory := Inventory.new()
var state := State.CLOSED

var _player: Node3D
var _camera: Camera3D
var _back_transform: Transform3D     # where the pack sits on your back
var _normal_fov := 75.0
var _tween: Tween

@onready var _model: Node3D = $Model
## The flap is optional: a plain box placeholder without one still works.
@onready var _flap_hinge: Node3D = get_node_or_null("Model/FlapHinge")
@onready var _ui: InventoryUI = $UILayer/InventoryUI


func _ready() -> void:
	_player = get_parent() as Node3D
	_back_transform = _model.transform     # remember the "on your back" pose from the scene

	var items: Array[ItemData] = starting_items.duplicate()
	if items.is_empty():
		for path in DEFAULT_ITEMS:
			items.append(load(path))
	for item in items:
		inventory.add_new(item)

	_ui.setup(inventory, self)
	_ui.hide_now()

	if not InputMap.has_action("backpack"):
		push_error("Backpack: add an Input Map action called 'backpack' (key B).")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("backpack"):
		toggle()
		get_viewport().set_input_as_handled()
	elif state == State.OPEN and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if state == State.CLOSED:
		open()
	elif state == State.OPEN:
		close()
	# While OPENING or CLOSING, ignore the key so the animation can't glitch.


## True while the pack is open or moving. Other scripts (pressing E, pressing R)
## use this to say "not now, you're busy with your backpack".
func is_busy() -> bool:
	return state != State.CLOSED


func open() -> void:
	if state != State.CLOSED:
		return
	# Stand still only (Brandon's rule): you can't open it mid-jump or mid-fall.
	if not _is_on_ground():
		message.emit("Stand still to open your backpack")
		return
	_camera = get_viewport().get_camera_3d()
	if _camera == null:
		push_warning("Backpack: no active camera found.")
		return

	state = State.OPENING
	_set_player_control(false)
	_normal_fov = _camera.fov

	# Move the pack under the camera WITHOUT it jumping: reparent keeps its world
	# position (true), so the swing starts from where it sits on your back.
	_model.reparent(_camera, true)

	var tween := _new_tween()
	# 1. Swing it off your right shoulder... (parallel() = at the same time as the line before)
	tween.tween_property(_model, "position", shoulder_position, step_time)
	tween.parallel().tween_property(_model, "quaternion", _tilt(shoulder_tilt), step_time)
	tween.parallel().tween_property(_model, "scale", Vector3.ONE, step_time)
	# 2. ...and round to in front of you. Two short moves look like one curved swing.
	tween.tween_property(_model, "position", front_position, step_time)
	tween.parallel().tween_property(_model, "quaternion", _tilt(front_tilt), step_time)
	# 3. Flap opens (skipped if the model has no FlapHinge).
	if _flap_hinge != null:
		tween.tween_property(_flap_hinge, "rotation_degrees:x", flap_open_degrees, step_time * 0.8)
	# 4. Look down into it: zoom the camera and tip the pack toward you.
	tween.tween_property(_camera, "fov", zoom_fov, step_time)
	tween.parallel().tween_property(_model, "position", look_position, step_time)
	tween.parallel().tween_property(_model, "quaternion", _tilt(look_tilt), step_time)
	# 5. Show the grid, then we're open.
	tween.tween_callback(_ui.show_animated)
	tween.tween_callback(_finish_opening)


func close() -> void:
	if state != State.OPEN:
		return
	state = State.CLOSING
	_ui.hide_animated()

	var tween := _new_tween()
	# Same steps, backwards.
	tween.tween_interval(0.1)
	tween.tween_property(_camera, "fov", _normal_fov, step_time)
	tween.parallel().tween_property(_model, "position", front_position, step_time)
	tween.parallel().tween_property(_model, "quaternion", _tilt(front_tilt), step_time)
	if _flap_hinge != null:
		tween.tween_property(_flap_hinge, "rotation_degrees:x", 0.0, step_time * 0.6)
	tween.tween_property(_model, "position", shoulder_position, step_time)
	tween.parallel().tween_property(_model, "quaternion", _tilt(shoulder_tilt), step_time)
	tween.tween_callback(_return_model_to_back)
	tween.tween_property(_model, "position", _back_transform.origin, step_time)
	tween.parallel().tween_property(_model, "quaternion", _back_transform.basis.get_rotation_quaternion(), step_time)
	tween.parallel().tween_property(_model, "scale", _back_transform.basis.get_scale(), step_time)
	tween.tween_callback(_finish_closing)


## Instantly close, no animation. For when something interrupts you
## (attacked, a cutscene starts, you die...).
func slam_shut() -> void:
	if state == State.CLOSED:
		return
	if _tween != null:
		_tween.kill()
	_ui.hide_now()
	if _flap_hinge != null:
		_flap_hinge.rotation_degrees.x = 0.0
	if _camera != null:
		_camera.fov = _normal_fov
	_return_model_to_back()
	_model.transform = _back_transform
	_finish_closing()


## Pick up an item from the ground (you end up holding it).
func pick_up(item: ItemData) -> bool:
	if inventory.pick_up(item):
		message.emit("Picked up " + item.display_name)
		return true
	message.emit("No room in your backpack")
	print("No room in your backpack")
	return false


## Take an item out of the inventory and set it on the ground in front of you.
func drop_item(from: Dictionary) -> void:
	var item := inventory.drop(from)
	if item == null:
		return
	var dropped: DroppedItem = DROPPED_ITEM_SCENE.instantiate()
	dropped.item = item                               # set BEFORE adding, so its _ready() sees it
	get_tree().current_scene.add_child(dropped)
	var forward := -_player.global_transform.basis.z  # -Z is "forward" in Godot
	dropped.global_position = _player.global_position + forward * 1.2 + Vector3.UP * 0.8


# --- Private helpers -------------------------------------------------------------

func _finish_opening() -> void:
	state = State.OPEN
	opened.emit()


func _finish_closing() -> void:
	state = State.CLOSED
	_set_player_control(true)
	closed.emit()


func _return_model_to_back() -> void:
	if _model.get_parent() != self:
		_model.reparent(self, true)


## A rotation that tips the pack's top toward the camera by `degrees`.
func _tilt(degrees: float) -> Quaternion:
	return Quaternion.from_euler(Vector3(deg_to_rad(degrees), 0.0, 0.0))


func _new_tween() -> Tween:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)   # smooth start and stop
	return _tween


## On the floor? Players (CharacterBody3D) know this; anything else counts as "yes".
func _is_on_ground() -> bool:
	var body := _player as CharacterBody3D
	return body == null or body.is_on_floor()


## Freeze or unfreeze the player while the pack is open.
## Works with the ProtoController player (it has can_move, capture_mouse, release_mouse)
## and falls back to plain mouse settings for any other player script.
## (ProtoController sets its speed to zero when can_move is false: that's the "stand still".)
func _set_player_control(enabled: bool) -> void:
	# _player is typed as a plain Node3D, which has no "can_move" or
	# "capture_mouse". set() and call() look them up by NAME at runtime instead.
	if _player != null and "can_move" in _player:
		_player.set("can_move", enabled)
	if enabled:
		if _player != null and _player.has_method("capture_mouse"):
			_player.call("capture_mouse")
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		if _player != null and _player.has_method("release_mouse"):
			_player.call("release_mouse")
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
