---
name: bug
description: Help Brandon find and fix a bug in Valley of Voices. Use when he says something is broken, not working, "doesn't work", there's an error or a crash, or runs /bug. Gathers the facts, finds the cause BEFORE changing anything, explains it simply, asks before fixing, then teaches him how to find it himself next time.
---

# Fix a bug

Brandon is new to programming. Be calm and clear; bugs are normal. **Change nothing until you know the cause and Brandon says yes.**

## 1. Get the facts
If his message doesn't already say, ask for the missing ones (in one message, as a short list), then wait:
1. **What you did:** which scene, F5 (whole game) or F6 (this scene), which keys you pressed.
2. **What you expected** to happen.
3. **What happened** instead.
4. **The exact error** from Godot's Output or Debugger panel (copy-paste the red text; a screenshot is fine if it *looks* wrong).
5. **What you changed recently** (scripts, scenes, Inspector values).

If he says he doesn't know where to find the error, tell him: bottom of the Godot editor → **Output** tab (the log), and **Debugger** tab → **Errors** (red lines, with the file and line number).

## 2. Look at the evidence
- Read `C:\Users\brand\AppData\Roaming\Godot\app_userdata\Valley of Voices\logs\godot.log` if you can reach it. Look for `ERROR`, `SCRIPT ERROR` and `WARNING` lines and the file:line they point to. (It holds the most recent run.)
- Check what changed: `git status` and `git diff` in the project folder. If `git` isn't on the PATH, use GitHub Desktop's copy (search `%LOCALAPPDATA%\GitHubDesktop` for `cmd\git.exe`), or ask him to look at GitHub Desktop's Changes tab.
- Read the scripts and scenes involved (`.tscn` files show which script is attached, node names and Inspector values). Read every file fresh; Brandon may have changed it.

## 3. Find the cause, then explain it
- Find the real cause before suggesting anything. If you can't be sure, say what you suspect and give him a `print()` to add that will prove it, then wait for the result.
- Explain in plain words: **what went wrong**, **why** (the idea behind it, e.g. "the node path changed when you renamed the node, so `$Model` finds nothing and returns null"), and where (file:line or node).

## 4. Suggest the fix, ask first
- Describe the fix and why it works. Ask: "Want me to apply it?"
- **One-line or one-value fix:** don't apply it. Tell him the exact file, line number, what's there now and what to change it to (or the node and Inspector property). Let him do it.
- **Scene changes** (nodes, attaching scripts, Inspector): always his job. Give exact editor steps.
- **Bigger code fixes**, after he says yes: follow `CLAUDE.md`'s code rules. If the bug is in real logic (inventory, maths, saving), add a test in `res://tests/` that would have caught it. Update the script's vault mirror page (`Change history` + `Full code`). Never edit `addons/`. If Godot has the file open, tell him to choose **Reload**.
- Tell him how to check it's fixed (F5/F6 and what to do).

## 5. Teach him to find it himself
End with a short "Next time" section:
- **Where to look:** which panel or message pointed to it (Debugger → Errors, the Output line, the Remote scene tree while the game runs, the Inspector).
- **What `print()` to add** and where, with the exact line, e.g. `print("picked up: ", item.name)`, and what output would have revealed the problem.
- The general lesson in one sentence (e.g. "null errors usually mean a node path or a missing assignment").
