class_name StatusEffects
extends Node
## A list of what's affecting you right now: "HANDS FULL", "HEAVY LOAD",
## "TOXIC AIR"... (later: spores in your lungs, step 9).
##
## Any system can REPORT an effect by a short id, and take it away again:
##   status.set_effect(&"toxic_air", "TOXIC AIR")
##   status.clear_effect(&"toxic_air")
## The wrist monitor only READS the list. So a new effect (spores, a broken
## mask...) needs no change to the wrist at all.
## Lives as a child of the player: main.tscn → ProtoController → StatusEffects.
## Vault: wiki/2 Building It/Code/player/status_effects.gd

## Emitted when an effect starts, ends or changes its text.
signal changed

# id → text. A Dictionary in Godot 4 remembers the order things were added,
# so effects show up in the order they started.
var _effects: Dictionary = {}


## Start an effect, or update its text. `&"..."` makes a StringName: a fast,
## exact name, so "toxic_air" can't be mixed up with "Toxic Air".
func set_effect(id: StringName, text: String) -> void:
	if _effects.get(id) == text:
		return   # nothing new: don't make the wrist redraw for nothing
	_effects[id] = text
	changed.emit()


## End an effect. Fine to call even if it isn't active.
func clear_effect(id: StringName) -> void:
	if _effects.erase(id):   # erase() returns true only if it was there
		changed.emit()


func has_effect(id: StringName) -> bool:
	return _effects.has(id)


## The texts of all active effects, oldest first.
func get_lines() -> PackedStringArray:
	var lines := PackedStringArray()
	for text in _effects.values():
		lines.append(text)
	return lines
