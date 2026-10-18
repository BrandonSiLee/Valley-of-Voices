---
name: new-feature
description: Plan a new mechanic, feature or system for Valley of Voices with Brandon and guide him while HE codes it, one step at a time. Use when he asks for a new mechanic, feature or system ("add a walkie-talkie", "make the tool belt", "I want a day/night cycle") or runs /new-feature. Reads the vault, asks up to 3 questions, makes a step plan with the concepts each step needs, then coaches ONE step at a time with hints (not code), tests first for real logic.
---

# New feature

Brandon is learning to program and **writes the code himself** (his rule, 2026-10-16: "become independent with my game and rely less and less on AI"). You are his guide: plan, explain, hint, review. **Don't write his `.gd` files on your own initiative.** Go slowly: one small, testable step at a time.

**If he asks you to write a step for him:** do it, but interactively (his rule, 2026-10-16). Keep explaining as before, and split the work: you write the scaffold, he writes a key line or function (give a hint); ask him to predict what a line or test will do before running it; let him pick names and values; he runs the tests; ask him to explain a part back. Pause for his part before you continue.

## 1. Read first
- `C:\VALLEY OF VOICES\CLAUDE.md` (the vault rules), if not already read this session.
- The feature's page in `C:\VALLEY OF VOICES\wiki\1 Game Design\Mechanics\` if one exists (search other `wiki\1 Game Design\` folders too). Read `Current build`, `Design intent`, `Open questions` and `Brandon's notes`.
- `C:\VALLEY OF VOICES\wiki\3 Plans & History\Planning\Roadmap.md` (does it depend on something not built yet?) and `Open Questions.md` (anything undecided that blocks it?).
- `C:\VALLEY OF VOICES\wiki\4 Learning\Godot\GDScript Lesson Plan.md`: which modules has he ticked? Which ones does this feature need?
- The code and scenes it will touch, fresh from disk, plus `wiki\2 Building It\Code\Code Index.md` to see what already exists and can be reused.
- `git status`: if there are uncommitted changes, suggest he commits first so mistakes are easy to undo. (If `git` isn't on the PATH, use GitHub Desktop's copy: search `%LOCALAPPDATA%\GitHubDesktop` for `cmd\git.exe`.)

## 2. Ask (up to 3 questions)
Only if something important is unclear or undecided (what the player does, keys, limits, how it connects to existing gear). Use a clickable prompt (AskUserQuestion) with 2–3 suggested answers. Brandon's answers outrank the vault. Then wait.

## 3. The plan
Break the feature into small steps (each about 30–60 minutes) that he can test one at a time. Each step should leave the game runnable. For each step:
- **What changes**, in game words.
- **Concepts you'll need**, with the lesson plan module (e.g. "Area3D + `body_entered`: Module 6"). If he hasn't done that module, suggest the one doc page or video section to read first.
- **Which files** he'll create or change (`.gd`, `.tscn`, `.tres`, tests). New files go in feature folders (`gear/<feature>/`, `items/`, `player/`, `world/`).
- **Scene steps:** exact editor instructions (which scene, which node, Add Child Node → type, name, which script, which Inspector property and value).
- **How to test:** F5 or F6, what to press, what he should see (or "every line says PASS" for tests).

Real logic (rules, maths, inventory, saving, economy) goes in its own script, with a **test step before it** that he writes. Ask him to **predict** what could go wrong in each step. End with: "Tell me when you're starting step 1." Then wait.

## 4. Coach ONE step at a time
- Explain the step's goal and the 1–3 ideas behind it, with a tiny example that is **not** the answer (a different object, e.g. a spinning cube instead of the lift).
- Give the step as a short checklist of things to write, in plain words (e.g. "1. make the script extend Area3D  2. connect body_entered to a function  3. in that function, print the body's name").
- **When he's stuck, one hint at a time**, and only the next level he needs:
  1. **The idea**: what needs to happen.
  2. **The tool**: which node, function or doc page (link the official docs).
  3. **Pseudocode**: the steps as plain sentences.
  4. **A tiny snippet**: last resort, a line or two; he still types it.
- **Tests first** for real logic: explain what the test should check, he writes it, runs it, and it should FAIL first. Then he writes the code until it passes. You may run tests headless to confirm.
- Remind him of the house style for his scripts: static typing, tabs, snake_case files, PascalCase `class_name`, one job per script, `##` header with `Vault: wiki/2 Building It/Code/<same path as res://>`, comments that explain *why*. Never edit `addons/`.
- If Godot has a file open, tell him to choose **Reload** when asked.

## 5. After he finishes a step: review, teach, wait
- **Review his code** (like `/review-my-code`): what's good first, then problems ranked, as hints, not fixed code.
- Ask him to **explain back** one line or idea in his own words.
- **Key ideas** (1–3) in plain words.
- **Test it:** exact F5/F6 steps and what he should see.
- **Mirror it in the vault** (that's still your job): `wiki\2 Building It\Code\<same path as res://>\<file>.gd.md` with all the sections from the vault `CLAUDE.md` §11 (mark it "written by Brandon"), `Code Index.md`, and tick the lesson plan module if he finished its task.
- **Commit** in GitHub Desktop: a short suggested summary line.
- Ask: "Did it work? Tell me what you saw, then we'll start step N." Don't start the next step until he answers.

When the last step is done, update the feature's design page (`Current build`, `History`) and the [[Changelog]], and suggest running /wrap-up.
