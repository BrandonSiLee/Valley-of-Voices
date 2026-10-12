class_name BunkerAirZone
extends Area3D
## An invisible box that marks "inside the bunker": clean air comes back here.
##
## When a player walks in, it finds that player's AirTank and says
## enter_bunker(); when they walk out, leave_bunker(). The zone doesn't know
## anything about air maths: it only tells the tank where the player is.
## Put it on an Area3D (with a CollisionShape3D child) that covers the bunker.
## Vault: wiki/2 Building It/Code/gear/air_tank/bunker_air_zone.gd


func _ready() -> void:
	# Area3D shouts these signals by itself whenever a body walks in or out.
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	var tank := _find_air_tank(body)
	if tank:
		tank.enter_bunker()


func _on_body_exited(body: Node3D) -> void:
	var tank := _find_air_tank(body)
	if tank:
		tank.leave_bunker()


# Looks through the body's children for an AirTank. Rocks, dropped tools and
# anything else without a tank simply return null and are ignored.
func _find_air_tank(body: Node3D) -> AirTank:
	for child in body.get_children():
		if child is AirTank:
			return child as AirTank   # "as" = treat this Node as the AirTank it is
	return null
