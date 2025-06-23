# IGIPatch
A fan-made patch for Project IGI, currently in an early stage of development. Bug-fixing, QoL improvements and better compatibility with modern systems are the main goals of the patch.

# Installation
1. Find your IGI installation directory and backup the file 'pc\IGI.exe'.
2. Extract the contents of the ZIP archive (IGIPatch_vx.xx_XX_NoSetup.zip) to the root directory of your game, accept when prompted to replace IGI.exe.

# Configuration
Individual features of the patch can be tweaked by editing the file 'IGIPatch.ini' with a text editor (eg.: Notepad). Numeric constant '1' means true/enable, whereas '0' means false/disable.

# Supported game versions
- European/Chinese
- American
- Japanese

# Current feature list - v0.40 (updated 2025-06-23)
- CD check removal.
- Improved timer resolution (beyond microseconds).
- Fixed windows cursor being visible in windowed mode.
- Fixed cursor accuracy in fullscreen mode for menus.
- Added support for borderless window mode. Use command-line parameter 'Borderless' to turn it on.
- Fixed buffer overflow when retrieving display modes. This solves the very known graphics menu crash.
- Display modes below the max bit depth of the screen are no longer selectable. This has been done because the game is limited to only 64 display modes.
- Fixed Resolution listbox showing a wrong display mode; Resolution limit raised from 8192x8192x32 to 65536x65536.
- Added widescreen support; Screen stretching is disabled and FOV is automatically adjusted.
- Added debug features via command-line arguments: NoLightmaps, NoTerrainLightmaps, DebugText, Debug, Small, DebugKeys.
- Updated Borderless window mode:  Fixed incorrect background size for the loading screen; optimized cursor handling code.

# Known issues
1. Intro videos not playing:
- Install/register Indeo Video 5 (IV50) codec.
2. When playing with a resolution of 2K or above, the game falls back to 640x480:
- The game uses DirectX7, which is hardcoded to 2048x2048 pixels. Use UCyborg's Legacy Direct3D Resolution Hack or a wrapper without that limitation (eg.: dgVoodoo2).
3. Game crashes when loading a mission:
- Some ingame overlays (such as Rivatuner) are known to cause crashes. Disable them before launching the game.
4. Main menu looks pixelated when using Borderless Window mode:
- Menus are rendered at a resolution of 640x480; when using Borderless Window mode, the window gets upscaled to match the desktop resolution. Sadly, there is no solution for this yet.

# Credits
Special thanks to @neoxaero [(Sagatt)](https://github.com/Sagatt) for the immense help provided.
