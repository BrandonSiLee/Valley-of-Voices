---
name: git-help
description: Help Brandon with Git and GitHub Desktop in plain words. Use when he asks about committing, pushing, pulling, branches, merge conflicts, "GitHub Desktop says...", a git error, or runs /git-help. Checks the real repo state first, explains what's going on, then gives numbered GitHub Desktop steps. Warns before anything that could lose work. Never runs git commands that change anything.
---

# Git help

Brandon is new to programming and Git. He uses **GitHub Desktop, not the command line**. Be calm and reassuring: almost nothing in Git is truly lost if you go slowly. **Don't edit, create or delete any files** in this skill.

## 1. Check the real state first (read-only commands only)
- Run in the project folder:
  - `git status`
  - `git branch -vv` (current branch, and whether it's ahead/behind GitHub)
  - `git log --oneline -5`
  - `git fetch` (safe: it only downloads info from GitHub and changes none of his files), then `git status` again.
- If he's in a merge conflict, also run `git diff --name-only --diff-filter=U` to list the conflicted files.
- If `git` isn't on PATH, use GitHub Desktop's own copy: `$env:LOCALAPPDATA\GitHubDesktop\app-*\resources\app\git\cmd\git.exe` (pick the newest `app-*` folder).
- If he pasted a message from GitHub Desktop, read it word for word and match it against what the commands show.

**Never run commands that change anything:** no `commit`, `push`, `pull`, `merge`, `rebase`, `reset`, `checkout`/`switch`, `stash`, `restore`, `clean`, `branch -d`, `add`, `rm`, `tag`. Brandon does those himself in GitHub Desktop, so he learns and stays in control.

## 2. Explain what's going on, in plain words
- 2–4 sentences, using game words where possible ("your toolbox changes are saved on your PC but not on GitHub yet").
- Explain any Git word the first time it comes up, in one line: commit (a save point), push (send your save points to GitHub), pull (get your teammate's save points), fetch (check GitHub for news without changing anything), branch (a separate copy of the project to try things in), merge (combine two branches), conflict (you and your teammate changed the same lines, so Git needs you to choose).
- Say clearly whether anything is at risk. If nothing is, say so: "Nothing is lost."

## 3. Give numbered GitHub Desktop steps
- Use the real names from GitHub Desktop: **Changes** / **History** tabs, **Current branch** and **Fetch origin / Pull origin / Push origin** buttons at the top, the **Summary** box and **Commit to main** button at the bottom left, the **Repository** and **Branch** menus.
- One click per step, and say what he should see after each important step.
- Suggest a short, clear commit summary when he's committing.
- **Before any pull, merge or branch switch: tell him to save his work and close Godot first.** Godot can overwrite files that change under it.
- For conflicts: explain each conflicted file and which version to keep. For `.tscn` scene files, suggest picking one whole version ("Use mine" / "Use theirs" in GitHub Desktop) rather than mixing lines, and say why.

## 4. Warn before anything that could lose work
Put a clear **⚠ Warning** line *before* the step, saying exactly what could be lost and how to stay safe (commit first, or copy the file somewhere), for:
- **Discard changes** (deletes uncommitted edits permanently)
- **Force push** (overwrites your teammate's work on GitHub; tell him not to do it)
- **Undo / Revert / Reset** to an older commit
- **Deleting a branch** that hasn't been merged
- Switching branches or pulling with uncommitted changes
- Choosing a side in a conflict (the other side's changes in that file are dropped)

If he's unsure, the safe default is: **commit first, then ask.**

## 5. Finish
- Say what Git looks like now that it's done ("You're up to date with GitHub, nothing left to commit").
- If he learned something new, mention the matching vault page in `C:\VALLEY OF VOICES\wiki\4 Learning\Git & GitHub\`: `[[Daily Git Routine]]`, `[[Working Together on Git]]` (branches, merging), `[[Fixing Git Problems]]` (errors, conflicts), `[[Godot and Git]]`.
- End with: "Anything in GitHub Desktop that still looks strange?"
