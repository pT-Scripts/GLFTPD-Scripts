# GLFTPD Scripts by Petabyte

Welcome to the GLFTPD Scripts repository! This collection includes various scripts, addons, modules, and rewrites designed to enhance and extend the functionality of GLFTPD, a powerful FTP server software for Unix-like operating systems. Whether you're looking for bash scripts, Python scripts, TCL addons, or complete module rewrites, you'll find a range of utilities here to optimize and personalize your GLFTPD experience.

## Installation Instructions

### Bash Scripts (.sh files)
1. Place the `.sh` file in `/glftpd/bin`.
2. Run `chmod +x <script_name>.sh` to make the file executable.

### TCL Scripts (.tcl files)
1. Place the `.tcl` file in `eggdrop/scripts`.
2. Load the `.tcl` script in your eggdrop configuration and rehash the bot.

### Usage Tip
The main logic resides in the `.sh` file. Use the `.tcl` script to execute the `.sh` script and announce to IRC. If the script works with `./<script_name>.sh` in the terminal, it will work on IRC/eggdrop.

## Contents

### Bash Scripts
Automated tasks, system management, and utility scripts for GLFTPD.

### Python Scripts
Versatile scripts for various tasks and enhancements.

### TCL Addons
Extensions and modifications to enhance GLFTPD’s capabilities.

### Modules
Custom modules that add new features or improve existing ones.

### Rewrites
Updated or reimagined versions of existing scripts or functionalities.

## Current Released Scripts and Modules

### [pT-PreBot](https://github.com/pT-Scripts/pT-PreBot)
An IRC bot designed for managing pre-release data and integrating with MySQL databases, specifically tailored for eggdrop bots.

### [pT-tmdb for bot (!tmdb)](https://github.com/pT-Scripts/GLFTPD-Scripts)
Scripts for fetching TMDB info for GLFTPD on complete race.

### [pT-gtop for bot (!gtop)](https://github.com/pT-Scripts/GLFTPD-Scripts)
Scripts for displaying stats of affils/groups on GLFTPD.

### [pT-mediainfo for bot (!mediainfo)](https://github.com/pT-Scripts/GLFTPD-Scripts)
Scripts for running mediainfo on sample .mkv and .mp4 files and upload to ftp.

### [GLFTPD Space Theme v1.0](https://github.com/pT-Scripts/GLFTPD-Scripts)
A custom Space theme for GLFTPD.

More scripts and modules will be added soon.

## Get Help
Join us on Linknet IRC - #pT-scripts for support and assistance.

For further details, visit our GitHub repository: [GLFTPD Scripts](https://github.com/pT-Scripts/GLFTPD-Scripts).
