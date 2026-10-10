---
name: new-feature
description: Plan and build a new mechanic, feature or system for Valley of Voices step by step with Brandon. Use when he asks for a new mechanic, feature or system ("add a walkie-talkie", "make the tool belt", "I want a day/night cycle") or runs /new-feature. Reads the vault, asks up to 3 questions, makes a step plan labelled [Claude]/[Brandon], then builds ONE step at a time, tests first for real logic.
---

# New feature

Brandon is new to programming. He does scenes, assets, Inspector values and design; you write the code (see `CLAUDE.md`). Go slowly: one small, testable step at a time.

## 1. Read first
- `C:\VALLEY OF VOICES\CLAUDE.md` (the vault rules), if not already read this session.
- The feature's page in `C:\VALLEY OF VOICES\wiki\1 Game Design\Mechanics\` if one exists (search other `wiki\1 Game Design\` folders too). Read `Current build`, `Design intent`, `Open questions` and `Brandon's notes`.
- `C:\VALLEY OF VOICES\wiki\3 Plans & History\Planning\Roadmap.md` (does it depend on something not built yet?) and `Open Questions.md` (anything undecided that blocks it?).
- The code and scenes it will touch, fresh from disk, plus `wiki\2 Building It\Code\Code Index.md` to see what already exists and can be reused.
- `git status`: if there are uncommitted changes, suggest he commits first so mistakes are easy to undo. (If `git` isn't on the PATH, use GitHub Desktop's copy: search `%LOCALAPPDATA%\GitHubDesktop` for `cmd\git.exe`.)

## 2. Ask (up to 3 questions)
Only if something important is unclear or undecided (what the player does, keys, limits, how it connects to existing gear). Give each question 2–3 suggested answers so it's easy to reply. Brandon's answers outrank the vault. Then wait.

## 3. The plan
Break the feature into small steps (each about 30–60 minutes) that he can test one at a time. Each step should leave the game runnable. For each step:
- **[Claude]** (code) or **[Brandon]** (scenes, assets, Inspector, design).
- **What changes**, in game words.
- **Which files** (new or changed `.gd`, `.tscn`, `.tres`, tests). New files go in feature folders (`gear/<feature>/`, `items/`, `player/`).
- **[Brandon] steps:** exact editor instructions: which scene to open, which node to select, Add Child Node → which type, what to name it, which script to attach, which Inspector property and value.
- **How to test:** F5 or F6, what to press, what he should see (or "every line says PASS" for tests).

Put real logic (rules, maths, inventory, saving, economy) in its own script with a test step **before** it. End with: "Say go and I'll start with step 1." Then wait.

## 4. Build ONE step at a time
- Do only the current step. Re-read every file right before editing it.
- **Tests first** for real logic: write the failing test in `res://tests/`, tell him how to run it and that it should FAIL for now, then write the code that makes it pass.
- Follow `CLAUDE.md`'s code rules: static typing, tabs, snake_case files, PascalCase `class_name`, one job per script, `##` header with `Vault: wiki/2 Building It/Code/<same path as res://>`, beginner comments explaining *why*. Never edit `addons/`.
- Single-line or single-value changes: tell him the file, line and value and let him do it.
- If a step needs a scene change, give him the exact editor steps instead of editing the `.tscn`.
- If Godot has a file open, tell him to choose **Reload** when asked.
- Mirror every new or changed script in the vault (`wiki\2 Building It\Code\<same path as res://>\<file>.gd.md`, with all the sections from `CLAUDE.md`) and update `Code Index.md`, in the same step.

## 5. After each step: teach, then wait
- **What I did** (files, one line each).
- **Key ideas** (1–3), each in plain words with a tiny example.
- **Test it:** exact F5/F6 steps and what he should see.
- **Commit** in GitHub Desktop: a short suggested summary line.
- Ask: "Did it work? Tell me what you saw, then I'll do step N." Don't start the next step until he answers. If something broke, fix that first.

When the last step is done, update the feature's design page (`Current build`, `History`) and the [[Changelog]], and suggest running /wrap-up.
