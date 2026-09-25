;------------------------------------------------------------
; fpu constants
;------------------------------------------------------------

FPU_CONSTS.mmp:
; BackgroundFX_CreateMatrix_NEW
;.flt_0_5                dd 0.5
FPU_CONSTS.wsp:
; ComputerObject_ProjectRotatedPos_NEW
.flt_0_5                dd 0.5
; Computer_RunHandler
.flt_40_96             dd 40.959999
.flt_532_48            dd 532.47998

;------------------------------------------------------------
; proxy hooks
;------------------------------------------------------------

Display_vAspectRatio34  dd 0.75 ; 1.0 / Display_vAspectRatio43
Display_vAspectRatio43  dd 1.3333334 ; 4.0 / 3.0

;------------------------------------------------------------
; shared functions
;------------------------------------------------------------

;------------------------------------------------------------
; CDCheckPatch
;------------------------------------------------------------

;------------------------------------------------------------
; TimerTaskPatch
;------------------------------------------------------------

cstrInitTimerError      db 'Error initializing Timer task API.',0

;------------------------------------------------------------
; MouseCursorPatch
;------------------------------------------------------------

;Mouse_vScaleFactor      dd 255.0

;------------------------------------------------------------
; BorderlessPatch
;------------------------------------------------------------

cstrBorderless                  db 'Borderless',0

Main_aptWindowStyleList         dd Main_dwFullscreenWindowStyle,Main_dwWindowedWindowStyle,Main_dwBorderlessWindowStyle
Main_dwFullscreenWindowStyle    dd WS_POPUP + WS_VISIBLE + WS_CLIPSIBLINGS + WS_CLIPCHILDREN
Main_dwWindowedWindowStyle      dd WS_OVERLAPPED + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + WS_MINIMIZEBOX
Main_dwBorderlessWindowStyle    dd WS_POPUP + WS_VISIBLE + WS_CLIPSIBLINGS + WS_CLIPCHILDREN

;------------------------------------------------------------
; DisplayModesFix
;------------------------------------------------------------

Config_zDisplayDeviceFormat     db '%s',0
Config_zDisplayDeviceFormatEx1  db '%d - %s',0
Config_zDisplayDeviceFormatEx2  db '%d',0
;Config_zDisplayModeFormat       db '%dx%dx%d',0
Config_zDisplayModeFormat       db '%dx%d (%d-bit)',0

Config_zNoDisplayModesError     db 'No compatible display modes found on any D3D adapter.',0

;------------------------------------------------------------
; WidescreenPatch
;------------------------------------------------------------

;------------------------------------------------------------
; DebugFeaturesPatch
;------------------------------------------------------------

cstrNoLightmaps         db 'NoLightmaps',0
cstrNoTerrainLightmap   db 'NoTerrainLightmaps',0
cstrDebugText           db 'DebugText',0 ;Debugtext
cstrDebug               db 'Debug',0
cstrDebugKeys           db 'DebugKeys',0
cstrFixmeSmall          db 'Small',0

;------------------------------------------------------------
; MainMenuPatch
;------------------------------------------------------------

;------------------------------------------------------------
; NewFPSLimiterPatch
;------------------------------------------------------------

cstrInitAccTimerError   db 'Error initializing AccTimer task API.',0

cstrFPSLock             db 'FPSLock',0

;Mouse_vScaleFactorInv   dq 0.00392156862745098 ; 1.0 / 255.0
Mouse_vScaleFactorInv   dd 0.0039215689 ; 1.0 / 255.0

Mouse_tMouse_apvAnalogX_Tbl     dd Mouse_tMouse_vAnalogX_M100
                                dd Mouse_tMouse_vAnalogX_M010
                                dd Mouse_tMouse_vAnalogX_M110
                                dd Mouse_tMouse_vAnalogX_M001
                                dd Mouse_tMouse_vAnalogX_M101
                                dd Mouse_tMouse_vAnalogX_M011
                                dd Mouse_tMouse_vAnalogX_M111

Mouse_tMouse_apvAnalogY_Tbl     dd Mouse_tMouse_vAnalogY_M100
                                dd Mouse_tMouse_vAnalogY_M010
                                dd Mouse_tMouse_vAnalogY_M110
                                dd Mouse_tMouse_vAnalogY_M001
                                dd Mouse_tMouse_vAnalogY_M101
                                dd Mouse_tMouse_vAnalogY_M011
                                dd Mouse_tMouse_vAnalogY_M111
