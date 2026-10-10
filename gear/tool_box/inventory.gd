class_name Inventory
extends RefCounted
## The RULES of the Tool Box. No visuals here at all.
##
## It remembers what is in your hands, in the 3 belt slots and in the 6 x 4
## box grid, and it decides what is allowed (does it fit? can these swap?).
## The screen (inventory_ui.gd) only SHOWS this data and ASKS this script to
## change it. Keeping the rules in one place means they're easy to test and
## easy to sync in multiplayer later.
##
## RefCounted = a plain object that frees itself when nothing uses it.
## It isn't a Node, so it doesn't live in the scene tree.
## Vault: wiki/2 Building It/Code/gear/tool_box/inventory.gd

## Emitted after anything changes, so the screen knows to redraw.
signal changed

## The three places an item can be.
enum Area { HANDS, BELT, BOX }

const COLS := 6          # box grid width, in cells
const ROWS := 4          # box grid height, in cells
const BELT_SLOTS := 3
const NO_CELL := Vector2i(-1, -1)   # "there is no free space"

## What you're holding (one item, or null = empty hands).
var hands: ItemData = null

## The belt: one entry per slot, each an ItemData or null (empty).
var belt: Array[ItemData] = [null, null, null]

## Everything inside the box. Each entry is a Dictionary:
##   { "item": ItemData, "cell": Vector2i }
## "cell" is the TOP-LEFT cell the item covers.
var box: Array[Dictionary] = []


# --- Locations ---------------------------------------------------------------
# A "location" is a small Dictionary that says WHERE an item is (or should go):
#   {"area": Area.HANDS}
#   {"area": Area.BELT, "slot": 0}        (slots are 0, 1, 2)
#   {"area": Area.BOX, "index": 3}        an item already in the box (its place in `box`)
#   {"area": Area.BOX, "cell": Vector2i}  a spot in the grid to move something to
# These helper functions build them, so the rest of the code can't misspell a key.

static func hands_location() -> Dictionary:
	return {"area": Area.HANDS}


static func belt_location(slot: int) -> Dictionary:
	return {"area": Area.BELT, "slot": slot}


static func box_item_location(index: int) -> Dictionary:
	return {"area": Area.BOX, "index": index}


static func box_cell_location(cell: Vector2i) -> Dictionary:
	return {"area": Area.BOX, "cell": cell}


## Turns a location into words for the inspection panel, e.g. "Belt 2".
func describe_location(location: Dictionary) -> String:
	match location.area:
		Area.HANDS:
			return "Hands"
		Area.BELT:
			return "Belt %d" % (location.slot + 1)
		Area.BOX:
			if location.has("index"):
				var cell: Vector2i = box[location.index].cell
				return "Box (col %d, row %d)" % [cell.x + 1, cell.y + 1]
	return "?"


# --- Reading -----------------------------------------------------------------

## Returns the item at a location, or null if it's empty.
func get_item(location: Dictionary) -> ItemData:
	match location.area:
		Area.HANDS:
			return hands
		Area.BELT:
			return belt[location.slot]
		Area.BOX:
			if location.has("index"):
				return box[location.index].item
	return null


## Can an item of this size sit with its top-left corner at `cell`?
## `ignore_index` skips one box item (the one being moved, so it can't
## block itself).
func can_place_in_box(size: Vector2i, cell: Vector2i, ignore_index := -1) -> bool:
	# 1. It has to stay inside the 6 x 4 grid.
	if cell.x < 0 or cell.y < 0:
		return false
	if cell.x + size.x > COLS or cell.y + size.y > ROWS:
		return false

	# 2. It can't overlap another item. Rect2i = a rectangle of whole cells.
	var rect := Rect2i(cell, size)
	for i in box.size():
		if i == ignore_index:
			continue
		var other: Dictionary = box[i]
		var other_rect := Rect2i(other.cell, other.item.grid_size)
		if rect.intersects(other_rect):
			return false
	return true


## First free spot for an item of this size (scans row by row), or NO_CELL.
func find_free_cell(size: Vector2i, ignore_index := -1) -> Vector2i:
	for y in ROWS:
		for x in COLS:
			var cell := Vector2i(x, y)
			if can_place_in_box(size, cell, ignore_index):
				return cell
	return NO_CELL


# --- Changing (the only ways the inventory can change) ------------------------

## A NEW tool you just got: goes to the first free belt slot, otherwise the
## first space in the box. Returns false if there's no room anywhere
## (the caller then leaves it on the ground).
func add_new(item: ItemData) -> bool:
	if _stash(item):
		changed.emit()
		return true
	return false


## Picking a tool up off the ground: you end up HOLDING it.
## Whatever was already in your hands gets put away first (belt, then box).
func pick_up(item: ItemData) -> bool:
	if hands != null:
		if not _stash(hands):
			return false   # nowhere to put what you're holding
		hands = null
	hands = item
	changed.emit()
	return true


## Move an item from one location to another. Returns true if it worked.
## Moving onto a slot that's taken SWAPS the two items (if the other item
## fits back where the first one came from).
func move(from: Dictionary, to: Dictionary) -> bool:
	var item := get_item(from)
	if item == null:
		return false

	# Case 1: into the box grid.
	if to.area == Area.BOX:
		var ignore: int = from.index if from.area == Area.BOX else -1
		if not can_place_in_box(item.grid_size, to.cell, ignore):
			return false
		if from.area == Area.BOX:
			box[from.index].cell = to.cell       # just slide it to the new spot
		else:
			_remove(from)
			box.append({"item": item, "cell": to.cell})
		changed.emit()
		return true

	# Case 2: into hands or a belt slot.
	var target := get_item(to)
	if target == null:
		_remove(from)
		_set_slot(to, item)
		changed.emit()
		return true

	# Case 3: the slot is taken, so swap.
	if from.area == Area.BOX:
		# The other item must fit in the box where ours was.
		var old_cell: Vector2i = box[from.index].cell
		if not can_place_in_box(target.grid_size, old_cell, from.index):
			return false
		box[from.index] = {"item": target, "cell": old_cell}
	else:
		_set_slot(from, target)
	_set_slot(to, item)
	changed.emit()
	return true


## Take an item out entirely (to drop it on the ground). Returns the item.
func drop(from: Dictionary) -> ItemData:
	var item := get_item(from)
	if item != null:
		_remove(from)
		changed.emit()
	return item


## True if this item is anywhere: hands, belt or box.
## (Quests like "bring the hammer" can use this.)
func has_item(item: ItemData) -> bool:
	if hands == item or belt.has(item):
		return true
	for entry in box:
		if entry.item == item:
			return true
	return false


# --- Private helpers (the "_" means: only this script should call these) -----

func _stash(item: ItemData) -> bool:
	# Belt first...
	for slot in BELT_SLOTS:
		if belt[slot] == null:
			belt[slot] = item
			return true
	# ...then the first space in the box that fits.
	var cell := find_free_cell(item.grid_size)
	if cell != NO_CELL:
		box.append({"item": item, "cell": cell})
		return true
	return false


func _remove(location: Dictionary) -> void:
	match location.area:
		Area.HANDS:
			hands = null
		Area.BELT:
			belt[location.slot] = null
		Area.BOX:
			box.remove_at(location.index)


func _set_slot(location: Dictionary, item: ItemData) -> void:
	match location.area:
		Area.HANDS:
			hands = item
		Area.BELT:
			belt[location.slot] = item
