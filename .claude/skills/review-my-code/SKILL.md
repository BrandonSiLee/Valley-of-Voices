---
name: review-my-code
description: Review code Brandon wrote himself, like a kind teacher. Use when he says "review my code", "check what I wrote", "did I do this right" or runs /review-my-code. Praise first, then problems ranked by importance with HINTS (not fixed code), checked against CLAUDE.md's code rules, plus how to test. Read-only.
---

# Review my code

Brandon is learning by writing code himself. Your job is to help him fix it **himself**. **Don't edit, create or delete any files.**

## 1. What to review
- If he named a file (or `@file`), review that file.
- Otherwise look at his uncommitted changes: `git status` and `git diff` in the project folder. If `git` isn't on the PATH, use GitHub Desktop's copy (search `%LOCALAPPDATA%\GitHubDesktop` for `cmd\git.exe`).
- If there are no changes and no file named, ask which file to review, then wait.
- Ask what he was trying to do if it isn't obvious from the code or his message.
- Read whole files, not just the diff, and any script or scene his change talks to, so you judge it in context.

## 2. What you did well (first)
2–4 specific, honest points ("you typed every variable", "good name: `is_open` says exactly what it means"). No generic praise.

## 3. Problems, most important first
Order: bugs that break the game → things that will break later (null nodes, wrong types, missing checks) → `CLAUDE.md` rule breaks → style and tidiness.

For each problem:
- **Where:** file and line.
- **What's wrong**, in plain words.
- **Why it matters:** what the player or the next programmer would run into.
- **Hint:** a nudge towards the fix (a question, the name of the function or idea to look up, a link to a guide like `[[Godot Guide]]`). **Don't write the fixed code** unless he says "show me".

Keep it to the 5 most useful points. If there are more, say so and offer them after he fixes these.

## 4. Check against CLAUDE.md's code rules
A short checklist, ✅ or ❌ with one line each:
- Static typing (`var speed: float`, `-> void`).
- Naming: snake_case files, variables and functions; PascalCase `class_name`; tabs for indentation.
- `##` header at the top: what the script is and why it exists, plus `Vault: wiki/2 Building It/Code/<same path as res://>`.
- Comments explain *why* for a beginner.
- One job per script; rules/data kept separate from visuals.
- Nothing edited inside `addons/`.
- Real logic has a test in `res://tests/`.

## 5. How to test it
Exact steps: which scene to open, F5 (whole game) or F6 (this scene), which keys to press, and what he should see if it works. If tests exist (e.g. `tests/inventory_test.tscn`), tell him to run them with F6 and check every line says PASS.

End with: "Fix what you want, then run /review-my-code again and I'll look at it." Remind him the script's vault mirror page will need updating; that happens at /wrap-up.
