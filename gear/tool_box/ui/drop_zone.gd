class_name DropZone
extends Control
## The red hatch under the grid. Drop a tool here to set it on the ground.
## Vault: wiki/2 Building It/Code/gear/tool_box/ui/drop_zone.gd

var ui: InventoryUI
var _hover := false


func setup(owner_ui: InventoryUI) -> void:
	ui = owner_ui
	custom_minimum_size = Vector2(Inventory.COLS * InventoryUI.CELL, 46)
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true   # don't let the stripes draw outside the box


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var alpha := 0.55 if _hover else 0.3
	draw_rect(rect, Color(0.75, 0.1, 0.08, alpha))           # see-through red

	# Faint diagonal hazard stripes, every 18 pixels.
	var x := -size.y
	while x < size.x:
		draw_line(Vector2(x, size.y), Vector2(x + size.y, 0), Color(0, 0, 0, 0.18), 6.0)
		x += 18.0

	draw_rect(rect, Color("8a8a86"), false, 3.0)              # bolted steel frame
	draw_string(get_theme_default_font(), Vector2(0, size.y * 0.5 + 6),
			"DROP // SET IT ON THE GROUND", HORIZONTAL_ALIGNMENT_CENTER, size.x, 15,
			Color(1.0, 0.45, 0.4))


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var ok := ItemView.is_item_drag(data)
	if _hover != ok:
		_hover = ok
		queue_redraw()
	return ok


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	_hover = false
	queue_redraw()
	ui.request_drop(data.from)


func _notification(what: int) -> void:
	if (what == NOTIFICATION_DRAG_END or what == NOTIFICATION_MOUSE_EXIT) and _hover:
		_hover = false
		queue_redraw()
