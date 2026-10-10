class_name Interactor
extends Node
## Lets the player USE things: look at something and press E.
##
## Anything with an interact(player) function can be used: dropped tools
## now, doors, lamps and radios later. Each object decides for itself what
## "use" means; this script only finds what you're looking at.
## Also draws a small dot in the middle of the screen so you can aim.
## Put this node as a child of the player.
## Vault: wiki/2 Building It/Code/player/interactor.gd

## How far you can reach, in metres.
@export var reach := 2.5

var _player: CollisionObject3D


func _ready() -> void:
	_player = get_parent() as CollisionObject3D
	_add_crosshair()
	if not InputMap.has_action("interact"):
		push_error("Interactor: add an Input Map action called 'interact' (key E).")


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	# Don't grab things from the world while you're looking into the tool box.
	var tool_box := _player.get_node_or_null("ToolBox") as ToolBox
	if tool_box != null and tool_box.state != ToolBox.State.CLOSED:
		return

	var target := _find_target()
	if target != null and target.has_method("interact"):
		target.call("interact", _player)
		get_viewport().set_input_as_handled()


## Shoot an invisible line (a "ray") from the camera, straight ahead,
## and return the first thing it hits (or null).
func _find_target() -> Object:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return null
	var from := camera.global_position
	var to := from - camera.global_transform.basis.z * reach   # -Z = forward
	var query := PhysicsRayQueryParameters3D.create(from, to)
	if _player != null:
		query.exclude = [_player.get_rid()]                   # don't hit our own body
	var hit := camera.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	return hit.collider


func _add_crosshair() -> void:
	var layer := CanvasLayer.new()
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dot := ColorRect.new()
	dot.custom_minimum_size = Vector2(4, 4)
	dot.color = Color(1, 1, 1, 0.8)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(dot)
	layer.add_child(center)
	add_child(layer)
