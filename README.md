# IGIPatch
A fan-made patch for Project IGI, currently in an early stage of development. Bug-fixing, QoL improvements and better compatibility with modern systems are the main goals of the patch.

# Installation
1. Find your IGI installation directory and backup the file 'pc\IGI.exe'.
2. Extract the contents of the ZIP archive (IGIPatchDLL_vx.xx_NoSetup.zip) to the root directory of your game, accept when prompted to replace IGI.exe.

# Configuration
Individual features of the patch can be tweaked by editing the file 'IGIPatch.ini' with a text editor (eg.: Notepad). Numeric constant '1' means true/enable, whereas '0' means false/disable.

# Supported game versions
- European
- American
- Japanese

# Current feature list - v0.30 (updated 2025-06-15)
- CD check removal.
- Improved timer resolution (beyond microseconds).
- Fixed windows cursor being visible in windowed mode.
- Fixed cursor accuracy in fullscreen mode for menus.
- Added support for borderless window mode. Use command-line parameter 'Borderless' to turn it on.
- Fixed buffer overflow when retrieving display modes. This solves the very known graphics menu crash.
- Display modes below the max bit depth of the screen are no longer selectable. This has been done because the game is limited to only 64 display modes.

# Credits
Special thanks to @neoxaero [(Sagatt)](https://github.com/Sagatt) for the immense help provided.
