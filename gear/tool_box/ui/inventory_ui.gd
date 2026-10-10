class_name InventoryUI
extends Control
## The inventory SCREEN you see after diving into the Tool Box.
##
## Its only jobs: SHOW the Inventory, and turn mouse actions into requests
## ("move this there", "drop this"). The rules live in inventory.gd.
##
## Layout (built in code below so every piece is explained):
##   [ HANDS / BELT ]   [ INVENTORY: 6x4 grid + red drop hatch ]   [ inspection bay ]
## Vault: wiki/11 Code/gear/tool_box/ui/inventory_ui.gd

const CELL := 56   # size of one grid cell, in pixels

# Placeholder "rusty metal" palette. Swap for real textures later (vault: Tool Box).
const COL_PANEL := Color("3a332c")      # rusty sheet
const COL_FRAME := Color("5f7a52")      # light green frame around compartments
const COL_CELL := Color("26361f")       # dark green compartment
const COL_PLATE := Color("4a4d4c")      # painted metal spec plate
const COL_TEXT := Color("e2dccd")
const COL_DIM_TEXT := Color("9a9384")

var inventory: Inventory
var tool_box: ToolBox

var _grid: BoxGrid
var _hands_slot: EquipSlot
var _belt_slots: Array[EquipSlot] = []
var _bay_view: ItemView
var _bay: Control
var _plate_name: Label
var _plate_size: Label
var _plate_location: Label
var _plate_description: Label
var _status: Label
var _fade: Tween


## Called once by the Tool Box: "here's the inventory you show".
func setup(new_inventory: Inventory, owner_box: ToolBox) -> void:
	inventory = new_inventory
	tool_box = owner_box
	_build_layout()
	inventory.changed.connect(refresh)   # redraw whenever the rules say something changed
	refresh()


## Redraw everything from the inventory data.
func refresh() -> void:
	_grid.show_items(inventory.box)
	_hands_slot.show_item(inventory.hands)
	for i in _belt_slots.size():
		_belt_slots[i].show_item(inventory.belt[i])
	_clear_bay()


# --- Requests from the pieces (grid, slots, drop hatch) -----------------------

func request_move(from: Dictionary, to: Dictionary) -> void:
	if inventory.move(from, to):
		show_status("")
	else:
		show_status("It doesn't fit there.")


func request_drop(from: Dictionary) -> void:
	tool_box.drop_item(from)


## Fill the inspection bay with the item under the mouse.
func inspect(item: ItemData, location: Dictionary) -> void:
	_plate_name.text = "NAME      " + item.display_name.to_upper()
	_plate_size.text = "SIZE      %d x %d" % [item.grid_size.x, item.grid_size.y]
	_plate_location.text = "LOCATION  " + inventory.describe_location(location).to_upper()
	_plate_description.text = item.description

	# Show the item itself in the bay, centered, at true grid size.
	if _bay_view != null:
		_bay_view.queue_free()
	_bay_view = ItemView.new()
	_bay_view.setup(self, item, location, false)
	_bay_view.size = Vector2(item.grid_size) * CELL
	_bay_view.position = (_bay.size - _bay_view.size) * 0.5
	_bay.add_child(_bay_view)


func show_status(text: String) -> void:
	_status.text = text


# --- Fading in and out (called by the Tool Box) --------------------------------

func show_animated(seconds := 0.2) -> void:
	visible = true
	modulate.a = 0.0
	_restart_fade().tween_property(self, "modulate:a", 1.0, seconds)


func hide_animated(seconds := 0.15) -> void:
	var tween := _restart_fade()
	tween.tween_property(self, "modulate:a", 0.0, seconds)
	tween.tween_callback(hide)        # hide() runs after the fade finishes


func hide_now() -> void:
	if _fade != null:
		_fade.kill()
	visible = false


func _restart_fade() -> Tween:
	if _fade != null:
		_fade.kill()                  # stop a fade that's still running
	_fade = create_tween()
	return _fade


# --- Building the layout --------------------------------------------------------

func _build_layout() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP   # clicks here never reach the game behind

	# 1. Darken the world. While you're "inside" the box you can't see around you.
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.82)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	# 2. A centered metal panel with three columns.
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _metal_style(COL_PANEL, Color("1f1a16"), 16))
	center.add_child(panel)

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 20)
	panel.add_child(columns)

	columns.add_child(_build_slots_column())
	columns.add_child(_build_box_column())
	columns.add_child(_build_bay_column())


func _build_slots_column() -> Control:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	column.add_child(_label("", 22, COL_TEXT))    # spacer, lines up with the header

	_hands_slot = EquipSlot.new()
	_hands_slot.setup(self, Inventory.hands_location())
	column.add_child(_hands_slot)

	column.add_child(HSeparator.new())

	for i in Inventory.BELT_SLOTS:
		var slot := EquipSlot.new()
		slot.setup(self, Inventory.belt_location(i))
		_belt_slots.append(slot)
		column.add_child(slot)
	return column


func _build_box_column() -> Control:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	column.add_child(_label("INVENTORY", 22, COL_TEXT))

	_grid = BoxGrid.new()
	_grid.setup(self)
	column.add_child(_grid)

	var hatch := DropZone.new()
	hatch.setup(self)
	column.add_child(hatch)

	_status = _label("", 14, Color(1.0, 0.55, 0.45))
	column.add_child(_status)
	column.add_child(_label("B / ESC  CLOSE     DRAG  MOVE", 12, COL_DIM_TEXT))
	return column


func _build_bay_column() -> Control:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	column.custom_minimum_size.x = 240
	column.add_child(_label("", 22, COL_TEXT))    # spacer

	# The inspection bay: a recessed green box under a "work lamp" glow.
	var bay_frame := PanelContainer.new()
	bay_frame.add_theme_stylebox_override("panel", _metal_style(COL_CELL, COL_FRAME, 0))
	column.add_child(bay_frame)
	_bay = Control.new()
	_bay.custom_minimum_size = Vector2(240, 4 * CELL)
	_bay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bay_frame.add_child(_bay)
	var lamp := ColorRect.new()                    # soft warm light from above
	lamp.color = Color(1.0, 0.85, 0.55, 0.08)
	lamp.set_anchors_preset(Control.PRESET_TOP_WIDE)
	lamp.custom_minimum_size.y = 2 * CELL
	lamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bay.add_child(lamp)

	# The riveted spec plate: the ONLY metal tag on this screen.
	var plate := PanelContainer.new()
	plate.add_theme_stylebox_override("panel", _metal_style(COL_PLATE, Color("2a2c2b"), 10))
	column.add_child(plate)
	var lines := VBoxContainer.new()
	plate.add_child(lines)
	_plate_name = _label("", 13, COL_TEXT)
	_plate_size = _label("", 13, COL_TEXT)
	_plate_location = _label("", 13, COL_TEXT)
	_plate_description = _label("", 12, COL_DIM_TEXT)
	_plate_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_plate_description.custom_minimum_size.x = 220
	for line in [_plate_name, _plate_size, _plate_location, _plate_description]:
		lines.add_child(line)
	return column


func _clear_bay() -> void:
	if _bay_view != null:
		_bay_view.queue_free()
		_bay_view = null
	_plate_name.text = "NAME      -"
	_plate_size.text = "SIZE      -"
	_plate_location.text = "LOCATION  -"
	_plate_description.text = "Hover over a tool to inspect it."


# --- Small helpers ----------------------------------------------------------------

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


## A flat panel style: background colour, border colour, inner padding.
func _metal_style(background: Color, border: Color, padding: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(3)
	style.set_corner_radius_all(3)
	style.set_content_margin_all(padding)
	return style
