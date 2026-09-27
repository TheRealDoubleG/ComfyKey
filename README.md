# ComfyKey

**Version 0.1 – Beta**  
**Target: World of Warcraft: Forever 1.60.1 / Interface 16001**  
Author: **TheRealDoubleG**  
Discord: **the.real.double.g**

Safe named keybinding profiles with preview, recovery and import/export for WoW Forever.

A dedicated keybinding-profile tool. It intentionally does not also manage action bars or macros.

ComfyKey is developed specifically for **WoW: Forever**. Retail/Modern WoW, Midnight and WoW Classic are not compatibility targets.

## 0.1 Beta
- Added named snapshots of current WoW keybindings.
- Added diff preview before applying a profile.
- Added recovery snapshot and Restore action.
- Added text import/export.
- Refuses binding changes during combat and saves through WoW's binding API.

## Design notes
KeyBindProfiles and ProfileManager reinforce that keybinding tools are more reliable when they stay focused. ComfyKey manages bindings only.

The referenced third-party addons were used only to study public feature ideas, long-term bug patterns and architecture lessons. ComfyKey uses original Comfy Suite code and Blizzard UI assets.

## Commands
- /comfykey
- /ckey

## Safety
Profile application is explicit, previewable where relevant, and recovery data is saved before destructive changes.
