class_name ItemView
extends Control
## One item drawn on the inventory screen: a coloured block with its name.
## (Placeholder art. Later this can show an icon instead.)
##
## You can DRAG it. Godot's built-in drag and drop works like this:
##   1. The thing you grab answers _get_drag_data(): "here's what you're carrying".
##   2. Whatever is under the mouse is asked _can_drop_data(): "would you accept it?"
##   3. On release, that thing's _drop_data() is called.
## Vault: wiki/2 Building It/Code/gear/tool_box/ui/item_view.gd

var ui: InventoryUI
var item: ItemData
var location: Dictionary      # where this item is (see inventory.gd "Locations")
var draggable := true


func setup(owner_ui: InventoryUI, new_item: ItemData, new_location: Dictionary, can_drag := true) -> void:
	ui = owner_ui
	item = new_item
	location = new_location
	draggable = can_drag
	# IGNORE = the mouse passes straight through (used for the drag "ghost").
	mouse_filter = Control.MOUSE_FILTER_STOP if can_drag else Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_DRAG if can_drag else Control.CURSOR_ARROW
	mouse_entered.connect(_on_mouse_entered)


func _draw() -> void:
	# A slightly smaller rectangle leaves a gap so neighbours don't touch.
	var rect := Rect2(Vector2(3, 3), size - Vector2(6, 6))
	draw_rect(rect, item.color)                                  # fill
	draw_rect(rect, item.color.lightened(0.35), false, 2.0)      # outline (false = not filled)
	var font := get_theme_default_font()
	draw_string(font, Vector2(8, 18), item.display_name.to_upper(),
			HORIZONTAL_ALIGNMENT_LEFT, size.x - 14, 11, InventoryUI.COL_TEXT)


## Step 1 of drag and drop: you grabbed me.
func _get_drag_data(at_position: Vector2) -> Variant:
	if not draggable:
		return null

	# Where on the item you grabbed it. From the box: the exact spot.
	# From a slot: pretend you grabbed the middle of the first cell.
	var grab := at_position
	if location.area != Inventory.Area.BOX:
		grab = Vector2(InventoryUI.CELL, InventoryUI.CELL) * 0.5

	# A see-through copy at true grid size follows the mouse ("ghost").
	var ghost := ItemView.new()
	ghost.setup(ui, item, location, false)
	ghost.size = Vector2(item.grid_size) * InventoryUI.CELL
	ghost.position = -grab        # so the spot you grabbed stays under the mouse
	ghost.modulate.a = 0.7
	var holder := Control.new()   # the preview is placed at the mouse; the ghost is offset inside it
	holder.add_child(ghost)
	set_drag_preview(holder)

	return {"kind": "inventory_item", "item": item, "from": location, "grab_offset": grab}


## Is this drag data one of our items? (Other drags could exist one day.)
static func is_item_drag(data: Variant) -> bool:
	return data is Dictionary and data.get("kind", "") == "inventory_item"


# If you drop ONTO another item, pass the question to whatever holds it
# (the grid or a slot), with the mouse position converted to its coordinates.
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# Untyped on purpose: we call a function that plain Node doesn't have.
	var parent = get_parent()
	if parent != null and parent.has_method("_can_drop_data"):
		return parent._can_drop_data(at_position + position, data)
	return false


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var parent = get_parent()
	if parent != null and parent.has_method("_drop_data"):
		parent._drop_data(at_position + position, data)


func _on_mouse_entered() -> void:
	if ui != null:
		ui.inspect(item, location)
