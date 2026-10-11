---
name: start-day
description: Brandon's start-of-day routine for Valley of Voices. Use when he says "let's get the day started", "start the day", "good morning", "what's new" or runs /start-day. Checks GitHub, the Obsidian vault, Godot's logs and the roadmap, then suggests today's tasks.
---

# Start the day

Brandon is new to programming. Be clear, friendly and specific. **Don't edit, create or delete any files during this routine**: it only looks and reports.

## 1. FIRST: Brandon's inbox README, then his notes (Brandon's rule, 2026-10-10)
Do this before anything else, and treat what you find as the most important part of the report.
1. Read `C:\VALLEY OF VOICES\raw\inbox\README.md` in full. The bullet points under "Pointers go below" are Brandon's requests and rules for you. Also open any file it embeds or links (e.g. `![[some file.pdf]]`).
2. Check `C:\VALLEY OF VOICES\raw\inbox\` for any other files besides README.md.
   - **No design doc PDF in the inbox?** (Brandon's rule, 2026-10-11) Before continuing the routine, remind him with a clickable prompt (AskUserQuestion): "There's no design doc in `raw/inbox/`. Did your doc change since last session?" Options: **"I'll add it now"** (tell him how: Google Docs → File → Download → PDF, drag it into `raw/inbox/` in Obsidian, then say "done"; wait, then continue) · **"No changes"** (continue with the doc already in `raw/design-docs/`). Don't skip this reminder.
   - **A doc PDF is there?** It's the newest version: say so in the report and, once he says go, swap it in (vault `CLAUDE.md` §5: overwrite `raw/design-docs/Valley of Voices - Game IP (2026-10-10).pdf` + its `.md` transcription, old copy to the Recycle Bin) and list what changed in it.
3. Then find every page in `C:\VALLEY OF VOICES\wiki\` whose `## Brandon's notes` (or `## Brandon's notes / questions`) section has real text (not just `-`). Especially code pages in `wiki\2 Building It\Code\`: questions for you to answer.

## 2. Load the vault rules and where we left off
- Read `C:\VALLEY OF VOICES\CLAUDE.md` (the vault's own rules; it isn't loaded automatically). Follow its rules whenever you touch the vault today. Rules Brandon wrote in the inbox README outrank it.
- Read the **latest `wrap-up | Session summary` entry** at the end of `C:\VALLEY OF VOICES\wiki\log.md` (plus any entries after it): what was decided last time and what's still open. Use its "Still open" list when suggesting today's plan.

## 3. GitHub: what changed?
- Run `git status` and `git log --oneline -5` in the project folder.
- Run `git fetch` (safe: it only downloads info, changes nothing) and then `git status` again to see whether his teammate pushed something new.
- If `git` isn't on the PATH, use GitHub Desktop's copy: `$env:LOCALAPPDATA\GitHubDesktop\app-*\resources\app\git\cmd\git.exe` (pick the newest `app-*` folder). Only if that's missing too, ask Brandon to look at GitHub Desktop's Changes tab and the "Fetch origin" button instead.

## 4. Godot: any errors last time?
If you can reach `C:\Users\brand\AppData\Roaming\Godot\app_userdata\Valley of Voices\logs\godot.log`, read it and look for `ERROR` or `SCRIPT ERROR` lines.

## 5. What's next
Read `C:\VALLEY OF VOICES\wiki\3 Plans & History\Planning\Roadmap.md` and `...\Open Questions.md`.

## 6. Report, then wait
Reply with these headings, short and plain:
1. **Your inbox & notes:** each request in the inbox README first, then each note or question found: what it means and **step by step what Brandon should do** (which app, menu, node or property, and why). Answer code questions directly. Say which ones you'll handle (code/vault) once he says go.
2. **GitHub:** uncommitted changes? New commits from the teammate? If he needs to pull, tell him the exact GitHub Desktop steps (Fetch origin → Pull origin) and to close Godot first.
3. **Errors:** any from the last Godot run, in plain words, with a suggested fix.
4. **Suggested plan for today:** 1–3 small tasks. Label each **[You]** (scenes, assets, design) or **[Claude]** (code), roughly 1 hour each, with how to test each one.
5. Ask: "Which one do you want to start with?" Then wait.
