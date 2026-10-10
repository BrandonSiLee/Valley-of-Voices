---
name: start-day
description: Brandon's start-of-day routine for Valley of Voices. Use when he says "let's get the day started", "start the day", "good morning", "what's new" or runs /start-day. Checks GitHub, the Obsidian vault, Godot's logs and the roadmap, then suggests today's tasks.
---

# Start the day

Brandon is new to programming. Be clear, friendly and specific. **Don't edit, create or delete any files during this routine**: it only looks and reports.

## 1. Load the vault rules
Read `C:\VALLEY OF VOICES\CLAUDE.md` (the vault's own rules; it isn't loaded automatically). Follow its rules whenever you touch the vault today.

## 2. GitHub: what changed?
- Run `git status` and `git log --oneline -5` in the project folder.
- Run `git fetch` (safe: it only downloads info, changes nothing) and then `git status` again to see whether his teammate pushed something new.
- If `git` isn't available, say so and ask Brandon to look at GitHub Desktop's Changes tab and the "Fetch origin" button instead.

## 3. Obsidian: did Brandon leave notes?
- `C:\VALLEY OF VOICES\raw\inbox\`: any files besides README.md?
- Any page in `C:\VALLEY OF VOICES\wiki\` whose `## Brandon's notes` section has real text (not just `-`)?
- Especially code pages in `wiki\2 Building It\Code\`: questions for you to answer.

## 4. Godot: any errors last time?
If you can reach `C:\Users\brand\AppData\Roaming\Godot\app_userdata\Valley of Voices\logs\godot.log`, read it and look for `ERROR` or `SCRIPT ERROR` lines.

## 5. What's next
Read `C:\VALLEY OF VOICES\wiki\3 Plans & History\Planning\Roadmap.md` and `...\Open Questions.md`.

## 6. Report, then wait
Reply with these headings, short and plain:
1. **GitHub:** uncommitted changes? New commits from the teammate? If he needs to pull, tell him the exact GitHub Desktop steps (Fetch origin → Pull origin) and to close Godot first.
2. **Your notes:** for each note or question found, what it means and **step by step what Brandon should do** (which app, menu, node or property, and why). Answer code questions directly. Say which ones you'll handle (code/vault) once he says go.
3. **Errors:** any from the last Godot run, in plain words, with a suggested fix.
4. **Suggested plan for today:** 1–3 small tasks. Label each **[You]** (scenes, assets, design) or **[Claude]** (code), roughly 1 hour each, with how to test each one.
5. Ask: "Which one do you want to start with?" Then wait.
