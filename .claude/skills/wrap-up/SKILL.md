---
name: wrap-up
description: Brandon's end-of-session routine for Valley of Voices. Use when he says "let's wrap up", "done for today", "end the session" or runs /wrap-up. Summarises changes, updates the Obsidian vault, and prepares the commit.
---

# Wrap up the session

1. **What changed:** run `git status` and list every changed file with one plain line on why.
2. **Vault (follow `C:\VALLEY OF VOICES\CLAUDE.md`):**
   - For every changed `.gd` script, update its mirror page in `C:\VALLEY OF VOICES\wiki\2 Building It\Code\<same path as res://>\<file>.gd.md`: the full code, walkthrough and change history. Create the page if it's new, and update `Code Index.md`.
   - Add a dated entry to `C:\VALLEY OF VOICES\wiki\log.md`.
   - If a mechanic changed, update its page in `wiki\1 Game Design\Mechanics\` under "Current build".
   - Never rename vault page files.
3. **Tests:** say exactly how to run the relevant tests (e.g. open `tests/inventory_test.tscn` → F6 → every line PASS) and what to try in-game with F5.
4. **Commit:** give a short commit message. Don't commit or push yourself. Tell Brandon to commit and push in GitHub Desktop after testing.
5. **Recap for learning:** the 1–3 most important ideas from today, and one small exercise to try before next session.
