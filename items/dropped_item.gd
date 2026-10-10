class_name DroppedItem
extends RigidBody3D
## A tool lying on the ground. Look at it and press E to pick it up.
##
## It has an interact(player) function, so the player's Interactor can use it.
## (Same pattern as the lamp in the vault page "Giving Assets Behavior".)
## RigidBody3D = physics moves it, so it falls and tumbles when dropped.
## Vault: wiki/11 Code/items/dropped_item.gd

## How big one inventory cell is in the world, for the placeholder box.
const CELL_METERS := 0.12

## Which item this is. Set it before adding the node to the scene.
@export var item: ItemData


func _ready() -> void:
	if item == null:
		push_warning("DroppedItem has no item set.")
		return
	_build_body()


## Called by the player's Interactor when you look at this and press E.
func interact(player: Node) -> void:
	var tool_box := player.get_node_or_null("ToolBox") as ToolBox
	if tool_box == null:
		return
	if tool_box.pick_up(item):
		queue_free()    # it's in your hands now, so remove it from the world


func _build_body() -> void:
	# Size the box from the item's grid size: a 2x2 hammer is 24 x 24 cm.
	var box_size := Vector3(item.grid_size.x * CELL_METERS, 0.06, item.grid_size.y * CELL_METERS)

	# Looks: the item's own 3D scene if it has one, otherwise a coloured box.
	if item.world_scene != null:
		add_child(item.world_scene.instantiate())
	else:
		var mesh := BoxMesh.new()      # made in code, so each dropped item gets its own
		mesh.size = box_size
		var material := StandardMaterial3D.new()
		material.albedo_color = item.color
		mesh.material = material
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.mesh = mesh
		add_child(mesh_instance)

	# Physics shape: without one it would fall through the floor.
	var shape := BoxShape3D.new()
	shape.size = box_size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)
