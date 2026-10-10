---
name: quiz
description: Quiz Brandon on code from Valley of Voices that he worked on recently. Use when he says "quiz me", "test me", "check what I learned" or runs /quiz. Asks 5 questions one at a time (what a line does, what happens if you change something, which script is responsible), waits for each answer, explains gently, then gives a score and one topic to review with a link to his vault's 4 Learning folder. Read-only.
---

# Quiz me

Brandon is new to programming. This is practice, not an exam: be warm, encouraging and patient. **Don't edit, create or delete any files**, including vault pages: this skill only reads and asks.

## 1. Find what to ask about (silently, before the first question)
- Run `git log --oneline -10` and `git log --stat -5` in the project folder to see which scripts changed recently. If `git` isn't on PATH, use GitHub Desktop's copy: `$env:LOCALAPPDATA\GitHubDesktop\app-*\resources\app\git\cmd\git.exe`.
- Read those `.gd` files, and their mirror pages in the vault: `C:\VALLEY OF VOICES\wiki\2 Building It\Code\<same path as res://>\<file>.gd.md` (start from `Code Index.md`). The **Ideas you'll learn** and **Walkthrough** sections show what Brandon has already been taught, so ask about those.
- If Brandon named a topic or script ("quiz me on the inventory"), use only that.
- Never ask about something he hasn't seen yet.

## 2. Plan 5 questions (easiest first)
Mix these three kinds and use at least one of each:
1. **What does this line do?** Show 1–5 real lines in a ```gdscript block and ask what they do, or why they're there.
2. **What happens if I change…?** For example "What happens if you change `GRID_WIDTH` from 6 to 3, then press F5 and open the toolbox?"
3. **Which script is responsible?** For example "You press E while looking at the rope and it goes into the box. Which script noticed you pressed E?"

Rules for questions:
- Copy code exactly from the real files. Never make up code.
- Use game words (rope, toolbox, B key, E key) so the question feels like the game.
- Answers should be short: one sentence or a script name. No essays.
- Multiple choice (A/B/C) is fine for the first one or two questions if it helps him warm up.

## 3. Ask ONE question, then wait
- Write "Question 1 of 5", then the question. Stop and wait for his answer. **Never show the next question, or any answer, before he replies.**
- If he says "I don't know" or "skip", count it as 0 and explain the answer kindly. Not knowing is how you learn.

## 4. After each answer
- **Right:** say so, then explain *why* it's right in 1–2 sentences, adding one extra detail he might not know.
- **Partly right:** say which part is right, then fill in the missing part. Count it as ½.
- **Wrong:** be gentle ("Close, but…" / "Good guess, here's what actually happens…"). Explain the right answer in plain words, point to the exact line or file, and suggest how he could check it himself (add a `print()`, change the value and press F5/F6).
- Then go on to the next question.

## 5. Finish
- **Score:** "You got X / 5." (halves are allowed). Add one encouraging sentence that names something he clearly understands.
- **The one topic to review:** pick the idea behind his weakest answer and link the matching page in `C:\VALLEY OF VOICES\wiki\4 Learning\` as a wikilink, for example:
  - variables, types, functions, `if`/`for` → `[[GDScript Basics]]` (from scratch: `[[Programming From Zero]]`)
  - signals, `connect`, `emit` → `[[Signals]]`
  - nodes, scenes, `$Node`, `@onready` → `[[Nodes & Scenes]]`
  - `.tres`, `ItemData`, autoloads → `[[Resources & Autoloads]]`
  - the inventory screen, `Control` nodes → `[[Godot UI]]`
  - keys, `Input`, actions → `[[Input Map]]`
  - tweens, the lid animation → `[[Godot Animation]]`
  - errors, `print()` → `[[Debugging & Errors]]`
  - tests, `res://tests/` → `[[Testing, Debugging & Profiling]]`
  - naming, static typing, file layout → `[[GDScript Style Guide]]` / `[[Project Structure & Naming]]`

  Check the page exists first (Glob in `4 Learning`). Also mention that script's own mirror page in `2 Building It\Code\`.
- If he got 5/5, suggest a slightly harder quiz next time, or a "Try this" exercise from a mirror page.
- End with: "Want another round, or a quiz on a different script?"
