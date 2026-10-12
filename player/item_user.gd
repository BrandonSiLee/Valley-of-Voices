class_name ItemUser
extends Node
## Lets the player USE the item in their hands: press R (Input Map: use_item).
##
## For now only Filter Cartridges do something: they click into your Clean Air
## tank (+4 minutes, flowing in over about 5 seconds) and are used up, even
## on a full tank (then the air is wasted). Later, other items (a flare, a medkit...)
## can get their own "use" here too.
## The DECISION ("can I use this, and what happens?") is in the static function
## use_held_item(), so the tests can check it without a player or a scene.
## Lives as a child of the player: main.tscn → ProtoController → ItemUser.
## Vault: wiki/2 Building It/Code/player/item_user.gd

## What happened when you pressed R. An enum = a short list of named choices,
## so the code can't misspell "wasted" as "wastd".
enum UseResult { USED, WASTED, EMPTY_HANDS, CANT_USE }

var _tool_box: ToolBox
var _air_tank: AirTank


func _ready() -> void:
	# Our siblings under the player. get_node_or_null = "find it, or give me
	# null instead of crashing", so a missing node gives a clear error below.
	var player := get_parent()
	_tool_box = player.get_node_or_null("ToolBox") as ToolBox
	_air_tank = player.get_node_or_null("AirTank") as AirTank
	if _tool_box == null or _air_tank == null:
		push_error("ItemUser: needs ToolBox and AirTank next to it under the player.")
	if not InputMap.has_action("use_item"):
		push_error("ItemUser: add an Input Map action called 'use_item' (key R).")


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("use_item"):
		return
	if _tool_box == null or _air_tank == null:
		return
	# Not while you're looking into the tool box (same rule as pressing E).
	if _tool_box.state != ToolBox.State.CLOSED:
		return
	# Out of air = you've collapsed. Only a teammate can save you now (reviving).
	if _air_tank.air.is_empty():
		return

	var item := _tool_box.inventory.hands   # remember it: it may be used up below
	var result := use_held_item(_tool_box.inventory, _air_tank.air)
	_tell_player(result, item)
	get_viewport().set_input_as_handled()


## THE RULE: try to use whatever is in your hands on your air.
## `static` = it belongs to the script itself, not to one ItemUser node, so the
## tests can call ItemUser.use_held_item(...) without building a player.
static func use_held_item(inventory: Inventory, air: CleanAir) -> UseResult:
	var item := inventory.hands
	if item == null:
		return UseResult.EMPTY_HANDS
	if item.clean_air_seconds <= 0.0:
		return UseResult.CANT_USE        # a hammer can't fill your tank
	var was_full := air.is_full()        # check BEFORE using it, to know if it's wasted
	if not air.use_filter(item.clean_air_seconds):
		return UseResult.CANT_USE        # refused (e.g. you've collapsed): you keep it
	# Used up: take it out of your hands. drop() removes an item and hands it
	# back to us; we just don't put it on the ground, so it's gone.
	inventory.drop(Inventory.hands_location())
	return UseResult.WASTED if was_full else UseResult.USED


# Feedback in the Output panel for now. (Later: a sound, a click animation,
# and text on screen.)
func _tell_player(result: UseResult, item: ItemData) -> void:
	match result:
		UseResult.USED:
			print("Filter clicked in: +%d s of Clean Air flowing in" % roundi(item.clean_air_seconds))
		UseResult.WASTED:
			print("Filter clicked in, but your tank was already full: wasted.")
		UseResult.EMPTY_HANDS:
			print("Your hands are empty.")
		UseResult.CANT_USE:
			print("You can't use the %s on your air." % item.display_name)
