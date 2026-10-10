class_name EquipSlot
extends Control
## One square slot: your HANDS, or one of the 3 BELT slots.
## Looks like a recessed steel well. Shows the item in it and accepts drops
## (if it's taken, the inventory swaps the two items).
## Vault: wiki/11 Code/gear/tool_box/ui/equip_slot.gd

const SLOT_SIZE := Vector2(84, 84)

var ui: InventoryUI
var location: Dictionary
var _hover := false
var _view: ItemView


func setup(owner_ui: InventoryUI, new_location: Dictionary) -> void:
	ui = owner_ui
	location = new_location
	custom_minimum_size = SLOT_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP


## Show this item in the slot (or nothing, if item is null).
func show_item(item: ItemData) -> void:
	if _view != null:
		_view.queue_free()
		_view = null
	if item != null:
		_view = ItemView.new()
		_view.setup(ui, item, location)
		_view.position = Vector2(4, 4)
		_view.size = SLOT_SIZE - Vector2(8, 8)
		add_child(_view)


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, SLOT_SIZE)
	draw_rect(rect, Color("1c1916"))                                     # the dark well
	var edge := Color(0.35, 1.0, 0.35) if _hover else Color("6b6a66")   # green while you hover a drop
	draw_rect(rect, edge, false, 2.0)
	# Small label in the bottom corner: "HANDS" or "BELT 1".
	var text := ui.inventory.describe_location(location).to_upper() if ui != null else ""
	draw_string(get_theme_default_font(), Vector2(6, SLOT_SIZE.y - 6), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, InventoryUI.COL_DIM_TEXT)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var ok := ItemView.is_item_drag(data)
	_set_hover(ok)
	return ok


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	_set_hover(false)
	ui.request_move(data.from, location)


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END or what == NOTIFICATION_MOUSE_EXIT:
		_set_hover(false)


func _set_hover(value: bool) -> void:
	if _hover != value:
		_hover = value
		queue_redraw()   # ask Godot to call _draw() again
