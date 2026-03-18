# ✨ Oh My Posh + Git for PowerShell

A streamlined setup to supercharge your Windows PowerShell experience by combining **Oh My Posh** themes with a powerful set of **Git aliases** (inspired by Oh My Zsh).

## 🚀 Quick Start

1. **Allow script execution in Powershell**:
   ```
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Run the setup script**:
   ```
   Invoke-WebRequest https://raw.githubusercontent.com/JoseCm79/oh-my-posh-git/main/ohmyposh-setup.ps1 -OutFile "$env:TEMP\script.ps1"
   powershell -ExecutionPolicy Bypass -File "$env:TEMP\script.ps1"
   ```
   *Note: The script will install Oh My Posh and PSReadLine if they are missing. so it will ask for admin permissions.*

## 🌟 Key Features

### 🛠️ Git Aliases (OMZ Style)
Access over 100+ Git shorthands to speed up your workflow:
- `gst` → `git status`
- `glol` → `git log --graph --pretty=...`
- `gcam "message"` → `git commit --all --message "message"`
- `gpsh` → `git push`

### 🎨 Theme Management
- **`gthemes`**: Interactive CLI menu to browse and switch between Oh My Posh themes saved in `~/OhMyPoshThemes`.
- **Auto-persistence**: Your selected theme is saved and reloaded automatically when you open a new terminal.

### ❓ Interactive Help
- **`ghep`**: List all available aliases grouped by category.
- **`ghep -Search "term"`**: Find specific aliases quickly.

## 📦 Prerequisites
- **Windows 10/11**
- **PowerShell 7+** (Recommended) or Windows PowerShell
- **App Installer (Winget)**

---
Created with ❤️ to make developing on Windows easier.
