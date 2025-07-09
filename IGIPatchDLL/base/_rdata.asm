;--------------------------------------------------
; version detection stuff

num_version_ids         dd 3

build_id0_addr          dd 0x00541ECC
build_id0_pstr          dd build_id0_cstr
build_id1_addr          dd 0x00542624
build_id1_pstr          dd build_id1_cstr
build_id2_addr          dd 0x00540DC8
build_id2_pstr          dd build_id2_cstr

build_id0_cstr          db 'IGIMUTEX',0
build_id1_cstr          db 'IGIMUTEX',0
build_id2_cstr          db 'IGIMUTEX',0

;--------------------------------------------------
; ini file stuff

sec_main                du 'Main',0
key_enable              du 'EnableIGIPatch',0
def_enable              dd 1

sec_options             du 'Options',0
key_nocdcheck           du 'RemoveCDCheck',0
def_nocdcheck           dd 1
key_timerspatch         du 'ImprovedTimerResolution',0
def_timerspatch         dd 1
key_windowedfix         du 'FixWindowedCursor',0
def_windowedfix         dd 1
key_cursorfix           du 'FixCursorPrecision',0
def_cursorfix           dd 1
key_borderless          du 'BorderlessWindowPatch',0
def_borderless          dd 1
key_resolutions         du 'FixDisplayModes',0
def_resolutions         dd 1
key_widescreen          du 'WidescreenPatch',0
def_widescreen          dd 1
key_debugpatch          du 'EnableDebugFeatures',0
def_debugpatch          dd 1
key_mainmenures         du 'CustomMainMenuResolution',0
def_mainmenures         dd 1

key_mainmenuresx        du 'MainMenuResolutionX',0
def_mainmenuresx        dd -1
key_mainmenuresy        du 'MainMenuResolutionY',0
def_mainmenuresy        dd -1

;--------------------------------------------------
; Improved timer resolution
;--------------------------------------------------

cstrTimerAPIError_QPC   db 'GetPerformanceCounter called and no performance counter in system',0

;--------------------------------------------------
; borderless window
;--------------------------------------------------

dwFullscreenStyle       dd WS_POPUP
dwWindowedStyle         dd WS_BORDER+WS_DLGFRAME+WS_SYSMENU+WS_MINIMIZEBOX ;+WS_SIZEBOX+WS_MAXIMIZEBOX
dwBorderlessStyle       dd WS_POPUP

cstrBorderless          db 'Borderless',0

;--------------------------------------------------
; display modes patch
;--------------------------------------------------

cstrGetBPPError         db 'Failed to retrieve screen BPP.',0

;--------------------------------------------------
; widescreen patch
;--------------------------------------------------

Display_vAspectRatio34  dd 0.75 ; 3.0 / 4.0

;--------------------------------------------------
; debug patch
;--------------------------------------------------

cstrNoLightmaps         db 'NoLightmaps',0
cstrNoTerrainLightmap   db 'NoTerrainLightmaps',0
cstrDebugText           db 'DebugText',0 ;Debugtext
cstrDebug               db 'Debug',0
cstrDebugKeys           db 'DebugKeys',0
cstrFixmeSmall          db 'Small',0
