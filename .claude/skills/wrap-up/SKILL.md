---
name: wrap-up
description: Brandon's end-of-session routine for Valley of Voices. Use when he says "let's wrap up", "done for today", "end the session" or runs /wrap-up. Summarises changes, updates the Obsidian vault (after asking), makes an updated Word copy of his design doc, and prepares the commit.
---

# Wrap up the session

**Ask before changing the vault** (Brandon's rule, 2026-10-10): list what you'd change, ask with a clickable prompt (AskUserQuestion), and only write after he says yes. Any question to Brandon goes in a clickable prompt.

1. **What changed:** run `git status` and list every changed file with one plain line on why. (If `git` isn't on the PATH, use GitHub Desktop's copy: `$env:LOCALAPPDATA\GitHubDesktop\app-*\resources\app\git\cmd\git.exe`, newest `app-*` folder.)
2. **Vault (follow `C:\VALLEY OF VOICES\CLAUDE.md`), after asking:**
   - For every changed `.gd` script, update its mirror page in `C:\VALLEY OF VOICES\wiki\2 Building It\Code\<same path as res://>\<file>.gd.md`: the full code, walkthrough and change history. Create the page if it's new, and update `Code Index.md`.
   - Add a dated entry to `C:\VALLEY OF VOICES\wiki\log.md`.
   - If a mechanic changed, update its page in `wiki\1 Game Design\Mechanics\` under "Current build".
   - Never rename vault page files.
3. **Updated copy of Brandon's design doc (Word)** (Brandon's request, 2026-10-10), so he can update his own doc without searching the vault:
   - **Find today's decisions:** today's entries in `wiki\log.md`, today's rows in `wiki\3 Plans & History\History\Brandon's Notes History.md`, and today's `raw\notes-history\` file. Only **Brandon's decisions** (his words, or options he picked). Never Claude's ideas he didn't pick.
   - **Start from his doc:** `raw\design-docs\Valley of Voices - Game IP (2026-10-10).md` (the transcription of his newest doc). Keep his text, order and headings exactly.
   - **Add each decision in the matching section** of his doc (e.g. a night rule under NIGHT TIME, a quota rule under QUOTA SYSTEM), written in his words. Tag each added part with **[NEW YYYY-MM-DD]** and a yellow highlight. A decision with no matching section goes in a new section where it fits best, also tagged.
   - Build it as HTML in the scratchpad (`<h1>`/`<h2>` headings, nested `<ul>` lists, `<span style="background:#fff59d">` for new parts, Arial 11pt), then convert with `.claude\skills\wrap-up\html_to_docx.ps1 -HtmlPath <html> -DocxPath <docx>` (uses Microsoft Word on his PC).
   - Save to `C:\VALLEY OF VOICES\Doc Updates\YYYY-MM-DD Game IP (updated).docx`, add a row at the top of the table in `C:\VALLEY OF VOICES\Doc Updates\Doc Updates.md` (date · `[[YYYY-MM-DD Game IP (updated).docx]]` · one line on what changed; linked from Home), and send it with SendUserFile. Tell him: open it, copy the highlighted parts into his Google Doc (or upload the whole file to Google Drive → Open with Google Docs), then drop the newest PDF in `raw\inbox\` next session.
   - Skip this step if no design decisions were made today, and say so.
4. **Tests:** say exactly how to run the relevant tests (e.g. open `tests/inventory_test.tscn` → F6 → every line PASS) and what to try in-game with F5.
5. **Commit:** give a short commit message. Don't commit or push yourself. Tell Brandon to commit and push in GitHub Desktop after testing.
6. **Recap for learning:** the 1–3 most important ideas from today, and one small exercise to try before next session.
