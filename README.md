# Scripts

A collection of personal PowerShell utility scripts for Windows.

## Scripts

### DevDiary.ps1

Your personal work black box. Run it at the end of each day to automatically log your activity.

**What it records automatically:**
- Meetings from Outlook calendar (today)
- Teams calls accepted today (from local MSTeams logs)
- Git activity from your project folder
- "What I Did" auto-filled from today's commit messages
- Active dev servers (ports 3000–10000)

**What it asks you:**
- Commit any dirty repos? (if uncommitted changes exist)
- Any wins today?
- Any blockers?
- What's first tomorrow?

**Output:**
- `Documents\DevDiary\daily\YYYY-MM-DD.md` — full daily entry
- `Documents\DevDiary\DevDiary.xlsx` — one row per day spreadsheet
- `Documents\DevDiary\dashboard.html` — visual HTML overview

**Usage:**
```powershell
.\DevDiary.ps1              # log today (interactive)
.\DevDiary.ps1 -Week        # view last 7 days summary
.\DevDiary.ps1 -Search "auth"  # search all days for a keyword
.\DevDiary.ps1 -ShowToday   # view today's entry (no prompts)
```

---

### Kill-Port.ps1

Find what is using a port and kill it. Supports TCP and UDP.

**What it does:**
- Finds processes listening on the given port (TCP + UDP)
- Shows process name, PID, and full executable path
- Recognises common dev servers (Angular, React, Vite, Next.js, NestJS, etc.)
- Asks for confirmation before killing
- Supports killing multiple processes on the same port

**Usage:**
```powershell
.\Kill-Port.ps1              # interactive: prompts for a port
.\Kill-Port.ps1 -Port 3000   # directly target port 3000
.\Kill-Port.ps1 -List        # show all listening ports (no kill)
```

---

### Organize-Downloads.ps1

Cleans up your Downloads folder by moving old files into extension-based subfolders.

**What it does:**
- Moves files older than 30 days into folders named by extension (PDF, ZIP, XLSX, etc.)
- Moves old folders into a `Folders\` subfolder
- Files with unusual/no extensions go into `Others\`
- Skips managed folders (Scripts, PDF, ZIP, etc.) to avoid double-moving
- Handles duplicate filename conflicts automatically

**Usage:**
```powershell
.\Organize-Downloads.ps1     # run it (no parameters needed)
```

> Recommended: schedule monthly via Task Scheduler.

---

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- For `DevDiary.ps1`: Microsoft Outlook and Microsoft Excel installed (for calendar/spreadsheet features)
