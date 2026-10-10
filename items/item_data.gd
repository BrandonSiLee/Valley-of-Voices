class_name ItemData
extends Resource
## One KIND of item, e.g. "Hammer".
##
## A Resource is a data file. For every tool in the game we make one .tres
## file (right-click a folder > New Resource > ItemData) and fill these
## values in the Inspector. Scripts never hard-code item stats; they read them
## from these files. Vault: wiki/11 Code/items/item_data.gd

## Name shown in the inventory.
@export var display_name: String = "Tool"

## How many Tool Box grid cells it covers: x = columns (width), y = rows (height).
@export var grid_size: Vector2i = Vector2i(1, 1)

## Placeholder colour, used until the item has a real icon and model.
@export var color: Color = Color(0.6, 0.6, 0.6)

## One or two sentences for the inspection panel.
@export_multiline var description: String = ""

## Optional 3D scene to show when the item lies on the ground.
## Leave empty and a plain box in the item's colour is used instead.
@export var world_scene: PackedScene
