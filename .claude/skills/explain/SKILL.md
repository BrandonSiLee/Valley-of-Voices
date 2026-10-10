---
name: explain
description: Explain a script or function to Brandon as a total beginner. Use when he says "explain this", "what does this do", "walk me through" or runs /explain. Big picture first, then the code top to bottom in small chunks, then 3 exercises without answers. Read-only.
---

# Explain code

Brandon is new to programming. Be clear, friendly and patient. **Don't edit, create or delete any files**, including vault pages: this skill only reads and explains.

## 1. Which code?
- If Brandon named a file (or `@file`) or a function, use that.
- If he didn't, ask: "Which file or function should I explain?" Offer 2–3 likely choices (for example the file he's working on or the last one changed). Then wait.
- Read the whole file, even if he only asked about one function, so you understand the context.
- Also read its mirror page in the vault (`C:\VALLEY OF VOICES\wiki\2 Building It\Code\<same path as res://>\<file>.gd.md`) if it exists. If his `Brandon's notes / questions` section there has questions, answer them as part of the explanation.

## 2. The big picture (2–3 sentences)
- What this script is for, in game words ("this is what lets you pick up the rope").
- How it connects: which scene it's attached to, which scripts it talks to or listens to, and which input keys trigger it. Search the project (`.tscn` files and other scripts) to check; don't guess.

## 3. Top to bottom, in small chunks
- Go through the code in order, a few lines at a time (usually 3–10 lines per chunk). Show the chunk in a ```gdscript block, then explain it in plain words.
- Explain the *why*, not just the *what*: why it's written this way, what would break without it.
- **Every new idea gets a tiny example** the first time it appears: `extends`, `class_name`, variables and static typing (`: int`, `-> void`), `const`, `@export`, `@onready`, functions, `if`/`for`, arrays and dictionaries, signals and `connect`/`emit`, `_ready`/`_process`/`_input`, `$NodePath` and `get_node`, tweens, `await`, resources (`.tres`), groups… Keep the example to 1–3 lines, ideally from this game (rope, toolbox, player).
- Don't re-explain an idea that already came up in this answer; say "like the signal above".
- Link to an existing guide when there is one (for example `[[Godot Guide]]`) so he can read more.
- For a very long file, explain the first half, then ask "Want me to keep going?"

## 4. Three exercises (easiest first, no answers)
For each one:
- **Change:** exactly what to change (which file, which line or value, or which Inspector property).
- **Run:** F5 (whole game) or F6 (this scene), and what to do in game.
- **You should see:** what will happen if he got it right.

Make them small and safe: change a number, add a `print()`, flip a `true`/`false`, then something that needs a tiny bit of new code. **Don't give the answers.** Remind him to undo the changes (GitHub Desktop → right-click the file → Discard changes) if he doesn't want to keep them.

End with: "Any part you'd like me to explain again?"
