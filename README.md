# update_your_ubuntu

A modular Linux update script written in Bash, offering a friendly and interactive way to update packages across multiple sources:

✅ nala (APT frontend)

✅ flatpak

✅ snap

Includes:

1) Interactive menu to choose update sources

2) Pre-update summary of available packages

3) Logging with timestamps to /var/log/

4) Optional system reboot or shutdown after update

ASCII-art banner (because you deserve it)  ;)

📦 Features
Pre-flight scan: Detects available updates before any installation.

Selective update: Choose which sources to update: N, F, S, or A for all.

Log output: Every action is logged with timestamps.

Failsafe execution: Includes root check, error trapping, and safe fallbacks.

🔧 Requirements
Linux distribution using:

nala (installed via apt)

flatpak

snap

sudo privileges

Install nala if not present:

```sudo apt install nala```

🚀 Usage
Make the script executable:

```chmod +x update.sh```
Run it with root privileges:

```sudo ./update.sh```
You'll be prompted to:

Review available updates

Select which source(s) to update

Optionally restart or shut down your system

📁 Log Files
Update logs are saved to:

/var/log/system_update_YYYY-MM-DD_HH-MM-SS.log

This script does the boring stuff, so you don't have to. Enjoy & save your time. ;-)
