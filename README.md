# IGIPatch
A fan-made patch for Project IGI. Bug fixes, QoL improvements and better compatibility with modern systems are the main goals of the patch.

# Current feature list - v0.90 (updated 2026-09-25)

<details>
  <summary>View feature list</summary>

### General game fixes and improvements

- Added CD check removal.
- Improved timer resolution using higher-resolution timing APIs.
- Fixed Windows cursor visibility and positioning in windowed mode.
- Improved mouse cursor accuracy in menus while in fullscreen mode.
- Fixed the display-mode buffer overflow that caused the well-known Graphics menu crash.
- Fixed the wrong resolution being shown as selected in the Graphics Configuration menu.
- Removed the 8192x8192 resolution limit; resolutions are now limited by the maximum supported pixel count (2,147,483,647).
- Display modes below 640x480x16 are now filtered out to help avoid exceeding the internal 64-entry limit.
- IGI is now DPI-aware, fixing incorrect game window sizes with Windows DPI scaling above 100%.

### Patching and configuration

- Added an external editor for installing and removing the IGIPatch DLL loader from the main executable, with an option to enable the `Large Address Aware` flag.
- Added an INI configuration system for configuring individual patches and features.
  - Configurable `Enabled` option to enable or disable the main patches and hooks.
  - Configurable `Debug` option to display patcher progress and error messages.
- Added a plugin system for loading external plugins.

### Window and display

- Added borderless window mode.
  - Enable it with the `Borderless` command-line argument.
  - Configurable window scaling modes through an INI setting.
- Added widescreen support with automatic aspect-ratio correction.
- Added proper widescreen viewport scaling with horizontal FOV expansion (`hor+`) or vertical FOV reduction (`vert-`).
  - Configurable viewport scaling mode through an INI setting.
  - Configurable INI setting to set viewport FOV in percentage.
- Fixed rendering and LOD distance calculations for `hor+` scaling mode.

### Main menu

- Main menu now supports a custom display mode, defaulting to the in-game resolution.
  - Configurable INI setting for resolution and color depth.
  - Configurable INI setting for background scaling mode ('No scaling', 'Stretch to fill' or 'Preserve aspect ratio').
  - Configurable INI setting for background color in areas not covered by the background picture.
  - Configurable INI setting to enable or disable `BackgroundFX`.
- Fixed scaling and positioning of main-menu elements for resolutions other than 640x480.

### Debug features

- Added debug features through command-line arguments: `NoLightmaps`, `NoTerrainLightmaps`, `DebugText`, `Debug`, `Small` and`DebugKeys`.
- Debug keys can now be used without completing all missions.

### Frame rate and timing

- Added a new FPS limiter with accurate, high-resolution timing.
  - Configurable INI settings for timing API selection, input update rate and maximum rendering FPS.
- Added a render interpolation phase between fixed 30 FPS game ticks for smoother rendering.
  - Added interpolation support for a wide range of moving game objects.
  - Configurable INI setting to enable or disable render interpolation; the `FPSLock` command-line argument can also be used to disable it.
- Added phase-aware input handling with precise mouse input deltas for each game phase (logic, interpolation and rendering).
  - Configurable INI settings for per-axis mouse sensitivity multipliers.
  - Configurable INI setting for the maximum mouse-sensitivity multiplier used by the in-game sensitivity slider.

</details>

# Supported game versions
- European/Chinese
- American (not currently supported in v0.90)
- Japanese (not currently supported in v0.90)

# Installation
1. Locate your IGI installation directory (`pc` is the root directory, if present). Optionally back up `IGI.exe`.
2. Extract the contents of `IGIPatch_vx.xx_XX_NoSetup.zip` to the root directory of the game.
3. Run `IGIPatchEditor.exe` and click `Patch` to install the IGIPatch DLL loader in `IGI.exe`.

# Deinstallation
1. Run `IGIPatchEditor.exe` and click `Restore` to remove the IGIPatch DLL loader from `IGI.exe`.
2. Delete the following files: `IGIPatch - Debug keys.txt`, `IGIPatch.dll`, `IGIPatch.ini` and `IGIPatchEditor.exe`.

# Configuration
Individual features of the patch can be tweaked by editing the file `IGIPatch.ini` with a text editor (e.g. `Notepad`). A value of `1` enables a feature, while `0` disables it.

# Known issues
1. Intro videos not playing:
- Install/register the Indeo Video 5 (IV50) codec. Videos may still not play in borderless/windowed mode.
2. When playing with a resolution of 2K or above, the game falls back to 640x480:
- The game uses DirectX 7, which imposes a 2048x2048 pixel resolution limit. Use UCyborg's `Legacy Direct3D Resolution Hack` or a wrapper without that limitation (e.g. `dgVoodoo2`).
3. Game crashes when loading a mission:
- Some in-game overlays (such as `RivaTuner`) are known to cause crashes. Disable them before launching the game.

# Credits
Special thanks to @neoxaero [(Sagatt)](https://github.com/Sagatt) for the immense help provided.
