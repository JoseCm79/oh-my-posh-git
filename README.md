# ✨ Oh My Posh + Git for PowerShell

A streamlined setup to supercharge your Windows PowerShell experience by combining **Oh My Posh** themes with a powerful set of **Git aliases** (inspired by Oh My Zsh).

## 🚀 Quick Start

1. **Allow script execution in Powershell**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Run the setup script**:
   ```powershell
   # Run the local script or download and run
   powershell -ExecutionPolicy Bypass -File "./ohmyposh-setup.ps1"
   ```
   *Note: The script will install Oh My Posh and PSReadLine if they are missing. It may require admin permissions for these installations.*

## 🌟 Key Features

### 🛠️ Git Aliases (OMZ Style)
Access over 100+ Git shorthands to speed up your workflow:
- `gst` → `git status`
- `glol` → `git log --graph --pretty=...`
- `gcam "msg"` → `git commit -am "msg"`
- `gpsh` → `git push`

### 📌 Directory Pins (Navigation)
- **`pin <name>`**: Fast jump to a saved directory.
- **`pin -a <name>`**: Save the current directory as a pin.
- **`pin`**: Open an interactive menu to navigate, search, or remove pins.
- **`pin -h`**: Show detailed help.

### 👤 Profile & SSH Management Github / Git
- **`gprof`**: Manage multiple Git identities (e.g., Personal vs. Work).
- **`gprof <id> -Name "John" -Email "john@work.com"`**: Save a profile.
- **`gprof <id>`**: Switch your global Git identity instantly.
- **`gssh`**: Instantly display and **copy your SSH public key** to the clipboard.
- **`gconfig`**: Quickly view or set your current Git user configuration.

### 🎨 Theme Management
- **`gthemes`**: Interactive CLI menu to browse and switch between Oh My Posh themes.
- **Auto-persistence**: Your selected theme is saved and reloaded automatically in every new session.

### ❓ Interactive Help
- **`ghelp`**: List all available aliases grouped by category (Basic, Config, Pins, etc.).
- **`ghelp [category]`**: Filter by category (e.g., `ghelp pins`).
- **`ghelp -Search "term"`**: Find specific aliases by keyword.

## 📦 Prerequisites
- **Windows 10/11**
- **PowerShell 7+** (Recommended) or Windows PowerShell
- **App Installer (Winget)**

---
Created with ❤️ to make developing on Windows easier.
