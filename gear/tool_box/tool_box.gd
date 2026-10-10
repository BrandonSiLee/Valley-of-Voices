class_name ToolBox
extends Node3D
## The player's Tool Box: worn on the lower back, opened with B.
##
## Put this scene as a CHILD of the player. When you press B:
##   1. the box swings from your back to in front of your eyes,
##   2. the lid opens,
##   3. the camera "dives" into the box,
##   4. the inventory screen fades in. The world keeps going, but you can't see it.
## Press B (or Esc) again and it all plays backwards.
##
## This script handles the 3D box, the animation and the player's controls.
## The inventory RULES are in inventory.gd and the SCREEN is in ui/inventory_ui.gd.
## Vault: wiki/2 Building It/Code/gear/tool_box/tool_box.gd

signal opened
signal closed
## Something to tell the player, e.g. "No room in your tool box".
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

## Where the box sits in front of the camera while you hold it
## (camera space: x = right, y = up, -z = forward; units are metres).
const HELD_POSITION := Vector3(0.0, -0.32, -0.6)
const HELD_TILT_DEGREES := 35.0       # tip the top of the box toward you
## The "dive in" pose: closer, and tipped so you look straight into the tray.
const DIVE_POSITION := Vector3(0.0, -0.12, -0.42)
const DIVE_TILT_DEGREES := 80.0

## Items you start with (drag .tres files in here). Empty = DEFAULT_ITEMS.
@export var starting_items: Array[ItemData] = []

@export_group("Animation")
## Seconds for each animation step. Smaller = snappier.
@export var step_time := 0.3
## Camera field of view while looking into the box (smaller = more zoomed in).
@export var zoom_fov := 45.0
## How far the lid swings open, in degrees.
@export var lid_open_degrees := -110.0

var inventory := Inventory.new()
var state := State.CLOSED

var _player: Node3D
var _camera: Camera3D
var _back_transform: Transform3D     # where the box sits on your back
var _normal_fov := 75.0
var _tween: Tween

@onready var _model: Node3D = $Model
@onready var _lid_hinge: Node3D = $Model/LidHinge
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

	if not InputMap.has_action("toolbox"):
		push_error("ToolBox: add an Input Map action called 'toolbox' (key B).")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toolbox"):
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


func open() -> void:
	if state != State.CLOSED:
		return
	_camera = get_viewport().get_camera_3d()
	if _camera == null:
		push_warning("ToolBox: no active camera found.")
		return

	state = State.OPENING
	_set_player_control(false)
	_normal_fov = _camera.fov

	# Move the box under the camera WITHOUT it jumping: reparent keeps its world
	# position (true), so the animation starts from where it sits on your back.
	_model.reparent(_camera, true)

	var tween := _new_tween()
	# 1. Swing the box round to in front of you. (parallel() = at the same time as the line before)
	tween.tween_property(_model, "position", HELD_POSITION, step_time)
	tween.parallel().tween_property(_model, "quaternion", _tilt(HELD_TILT_DEGREES), step_time)
	tween.parallel().tween_property(_model, "scale", Vector3.ONE, step_time)
	# 2. Lid opens.
	tween.tween_property(_lid_hinge, "rotation_degrees:x", lid_open_degrees, step_time * 0.8)
	# 3. Dive in: zoom the camera and tip the box toward you.
	tween.tween_property(_camera, "fov", zoom_fov, step_time)
	tween.parallel().tween_property(_model, "position", DIVE_POSITION, step_time)
	tween.parallel().tween_property(_model, "quaternion", _tilt(DIVE_TILT_DEGREES), step_time)
	# 4. Show the inventory screen, then we're open.
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
	tween.parallel().tween_property(_model, "position", HELD_POSITION, step_time)
	tween.parallel().tween_property(_model, "quaternion", _tilt(HELD_TILT_DEGREES), step_time)
	tween.tween_property(_lid_hinge, "rotation_degrees:x", 0.0, step_time * 0.6)
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
	_lid_hinge.rotation_degrees.x = 0.0
	if _camera != null:
		_camera.fov = _normal_fov
	_return_model_to_back()
	_model.transform = _back_transform
	_finish_closing()


## Pick up a tool from the ground (you end up holding it).
func pick_up(item: ItemData) -> bool:
	if inventory.pick_up(item):
		message.emit("Picked up " + item.display_name)
		return true
	message.emit("No room in your tool box")
	print("No room in your tool box")
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


## A rotation that tips the box's top toward the camera by `degrees`.
func _tilt(degrees: float) -> Quaternion:
	return Quaternion.from_euler(Vector3(deg_to_rad(degrees), 0.0, 0.0))


func _new_tween() -> Tween:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)   # smooth start and stop
	return _tween


## Freeze or unfreeze the player while the box is open.
## Works with the ProtoController player (it has can_move, capture_mouse, release_mouse)
## and falls back to plain mouse settings for any other player script.
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
