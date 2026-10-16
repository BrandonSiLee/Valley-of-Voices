class_name ItemData
extends Resource
## One KIND of item, e.g. "Hammer".
##
## A Resource is a data file. For every tool in the game we make one .tres
## file (right-click a folder > New Resource > ItemData) and fill these
## values in the Inspector. Scripts never hard-code item stats; they read them
## from these files. Vault: wiki/2 Building It/Code/items/item_data.gd

## Name shown in the inventory.
@export var display_name: String = "Tool"

## How many backpack grid cells it covers: x = columns (width), y = rows (height).
@export var grid_size: Vector2i = Vector2i(1, 1)

## Tick this for big things you carry with BOTH hands (an engine, a big radio).
## Holding one means no sprinting and no wrist device (Brandon, 2026-10-15).
## Small items leave this off: you can still sprint and check your wrist.
@export var two_handed: bool = false

## How heavy it is, in kilograms. Everything you carry adds up: a heavy load
## makes you slower and makes you breathe harder (more Clean Air used).
@export var weight_kg: float = 1.0

## Placeholder colour, used until the item has a real icon and model.
@export var color: Color = Color(0.6, 0.6, 0.6)

## One or two sentences for the inspection panel.
@export_multiline var description: String = ""

## Optional 3D scene to show when the item lies on the ground.
## Leave empty and a plain box in the item's colour is used instead.
@export var world_scene: PackedScene

## How many seconds of Clean Air this item gives when you use it
## (240 = 4 minutes). Only Filter Cartridges set this; every other tool
## keeps 0, which means "this can't fill your tank".
@export var clean_air_seconds: float = 0.0
