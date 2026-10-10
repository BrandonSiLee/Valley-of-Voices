class_name BoxGrid
extends Control
## The 6 x 4 grid inside the box.
## Draws the compartments, holds one ItemView per item, and accepts dropped
## items, showing a GREEN outline where an item fits and RED where it doesn't.
## Vault: wiki/11 Code/gear/tool_box/ui/box_grid.gd

var ui: InventoryUI

# The outline preview while dragging over the grid.
var _preview_cell := Inventory.NO_CELL
var _preview_size := Vector2i.ZERO
var _preview_valid := false

# A see-through layer on top of the items, so the outline is drawn ABOVE them.
# (A Control's own _draw() always paints BEHIND its children.)
var _overlay: Control


func setup(owner_ui: InventoryUI) -> void:
	ui = owner_ui
	custom_minimum_size = Vector2(Inventory.COLS, Inventory.ROWS) * InventoryUI.CELL
	mouse_filter = Control.MOUSE_FILTER_STOP

	_overlay = Control.new()
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.draw.connect(_draw_preview)     # when the overlay redraws, run _draw_preview
	add_child(_overlay)


## Rebuild the item blocks from the inventory's box list.
func show_items(entries: Array[Dictionary]) -> void:
	for child in get_children():
		if child != _overlay:
			child.queue_free()

	for i in entries.size():
		var entry: Dictionary = entries[i]
		var view := ItemView.new()
		view.setup(ui, entry.item, Inventory.box_item_location(i))
		view.position = Vector2(entry.cell) * InventoryUI.CELL
		view.size = Vector2(entry.item.grid_size) * InventoryUI.CELL
		add_child(view)

	move_child(_overlay, -1)   # keep the overlay on top (last child draws last)


func _draw() -> void:
	var cell := InventoryUI.CELL
	# Light green frame behind everything...
	draw_rect(Rect2(Vector2.ZERO, size), InventoryUI.COL_FRAME)
	# ...with a dark green compartment for every cell.
	for y in Inventory.ROWS:
		for x in Inventory.COLS:
			var compartment := Rect2(Vector2(x, y) * cell + Vector2(3, 3), Vector2(cell - 6, cell - 6))
			draw_rect(compartment, InventoryUI.COL_CELL)


func _draw_preview() -> void:
	if _preview_cell == Inventory.NO_CELL:
		return
	var color := Color(0.35, 1.0, 0.35) if _preview_valid else Color(1.0, 0.3, 0.3)
	var rect := Rect2(Vector2(_preview_cell) * InventoryUI.CELL, Vector2(_preview_size) * InventoryUI.CELL)
	_overlay.draw_rect(rect, color, false, 3.0)


## Which cell would the dragged item's top-left corner land on?
func _cell_for(at_position: Vector2, data: Dictionary) -> Vector2i:
	var top_left: Vector2 = at_position - data.grab_offset
	return Vector2i((top_left / InventoryUI.CELL).round())


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not ItemView.is_item_drag(data):
		return false
	var item: ItemData = data.item
	var cell := _cell_for(at_position, data)
	# An item being moved inside the box mustn't count as blocking itself.
	var ignore := -1
	if data.from.area == Inventory.Area.BOX:
		ignore = data.from.index

	_preview_cell = cell
	_preview_size = item.grid_size
	_preview_valid = ui.inventory.can_place_in_box(item.grid_size, cell, ignore)
	_overlay.queue_redraw()
	return _preview_valid


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var cell := _cell_for(at_position, data)
	_clear_preview()
	ui.request_move(data.from, Inventory.box_cell_location(cell))


func _notification(what: int) -> void:
	# Hide the outline when the drag ends or the mouse leaves the grid.
	if what == NOTIFICATION_DRAG_END or what == NOTIFICATION_MOUSE_EXIT:
		_clear_preview()


func _clear_preview() -> void:
	_preview_cell = Inventory.NO_CELL
	if _overlay != null:
		_overlay.queue_redraw()
