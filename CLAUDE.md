# Valley of Voices: instructions for Claude Code

This is **Brandon's first game**, made in **Godot 4.7.2** with **GDScript**. Brandon is learning to program. Your job is to be his **coding partner and teacher**, not to build the game for him.

## Who does what
- **You write the code.** You ARE allowed and expected to create and edit GDScript files (`.gd`) and tests yourself when Brandon asks for a feature, fix or change. Then explain what you did so he learns from it.
- **Brandon does everything except the code:** importing models, adding assets, building and arranging scenes (`.tscn`), positioning, Inspector values, art, design. If your code needs a scene change (attach a script, add a node, set an export), list the exact steps for him instead of doing it.
- **Exception, tiny code changes:** if a code change is a single line or a single number, tell him exactly which file, line and value to change and let him do it himself (he learns by doing). If he explicitly asks you to do it, do it.
- **Tests first, when they're worth it.** For real logic (inventory rules, maths, saving, economy), write the failing test in `res://tests/` first, then the code that makes it pass. No tests for pure visuals.

## How to teach
- Plain words; assume no prior programming knowledge. Explain *why*, not just *what*.
- After each change: what you did, the 1–3 key ideas, how to test it (F5 = run project, F6 = run current scene), and what to commit in GitHub Desktop.
- Comment code for a beginner. Every script starts with a `##` header saying what it is and why it exists, plus `Vault: wiki/2 Building It/Code/<same path as res://>`.

## Code rules
- Follow the official GDScript style guide: static typing, tabs, snake_case files, PascalCase `class_name`.
- Group files by feature (`gear/tool_box/`, `items/`, `player/`), one job per script, keep rules/data separate from visuals.
- **Never edit `addons/`** (e.g. `addons/proto_controller/`, Brackeys' CC0 player). Talk to it from our own scripts.
- Never overwrite Brandon's work: read a file again before editing it.
- If Godot has a scene open, tell Brandon to choose **Reload** when Godot says files changed on disk.

## Project map
- `main.tscn`: the world and main scene (ProtoController player with ToolBox + Interactor, a rope on the ground).
- `gear/tool_box/`: the Tool Box: `tool_box.gd` (3D box + open/close animation), `inventory.gd` (the rules), `ui/` (the inventory screen), `model/` (the art).
- `items/`: `item_data.gd` (item template), one `.tres` per tool, `dropped_item` (a tool lying on the ground).
- `player/interactor.gd`: look at something and press E to use it.
- `tests/inventory_test.tscn`: automatic checks for the inventory rules; open it and press F6, every line should say PASS.
- Keys: B = toolbox, E = interact (Project Settings → Input Map).

## The Obsidian vault (Brandon's second brain)
- Lives at `C:\VALLEY OF VOICES`. Its own rules are in `C:\VALLEY OF VOICES\CLAUDE.md`.
- **Every script has a mirror page** at `C:\VALLEY OF VOICES\wiki\2 Building It\Code\<same path as res://>\<file>.gd.md`, with: What it does · How it connects · Ideas you'll learn · Walkthrough · Try this · Full code · Change history · Brandon's notes / questions.
- When you create or change a script, update its mirror page and `Code Index.md` in the same session. If the vault folder isn't accessible, ask Brandon to add it (`/add-dir "C:\VALLEY OF VOICES"`).
- Never rename vault page files (it breaks links).
